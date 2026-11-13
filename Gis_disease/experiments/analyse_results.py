"""Summarise and plot BehaviorSpace results for the Delhi SEIR model.

Run the experiments headless (NetLogo 7), from the Gis_disease folder:

    NetLogo_Console --headless --model diseaseSpreading.nlogo \
        --setup-file experiments/scenarios.xml --table experiments/scenarios.csv
    NetLogo_Console --headless --model diseaseSpreading.nlogo \
        --setup-file experiments/epidemic_curves.xml --table experiments/curves.csv

then:

    python experiments/analyse_results.py
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent
LABELS = {
    (False, 0): "No intervention",
    (False, 50): "50% mask use",
    (True, 0): "Hospital isolation",
    (True, 50): "Isolation + 50% masks",
}


def _read(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path, skiprows=6)
    df = df.rename(columns={
        "[run number]": "run", "[step]": "step",
        "hospital-isolation?": "isolation", "mask-usage": "masks",
    })
    df["isolation"] = df["isolation"].astype(str).str.lower() == "true"
    return df


def summarise(path: Path) -> str:
    df = _read(path)
    final = df.sort_values("step").groupby("run").tail(1)
    rows = ["| Scenario | Runs | Peak infected (mean) | Peak day (mean) | Attack rate % (mean +/- sd) | Epidemic length, days |",
            "| --- | ---: | ---: | ---: | ---: | ---: |"]
    for key, label in LABELS.items():
        g = final[(final.isolation == key[0]) & (final.masks == key[1])]
        if g.empty:
            continue
        rows.append(
            f"| {label} | {len(g)} | {g['peak-infected'].mean():.1f} | {g['peak-day'].mean():.1f} "
            f"| {g['attack-rate'].mean():.1f} +/- {g['attack-rate'].std():.1f} | {g['day'].mean():.1f} |"
        )
    return "\n".join(rows)


def plot_curves(path: Path, out: Path) -> None:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    df = _read(path)
    metric = [c for c in df.columns if c.startswith("count people") and "infected" in c][0]
    df["day"] = df["step"] / 144.0
    fig, ax = plt.subplots(figsize=(8, 4.5))
    for key, label in LABELS.items():
        g = df[(df.isolation == key[0]) & (df.masks == key[1])]
        if g.empty:
            continue
        # Runs that end early keep their final value (no infected) afterwards.
        wide = g.pivot_table(index="step", columns="run", values=metric).ffill().fillna(0)
        mean = wide.mean(axis=1)
        ax.plot(mean.index / 144.0, mean.values, label=label, linewidth=2)
    ax.set_xlabel("Day")
    ax.set_ylabel("Infected people (mean of runs)")
    ax.set_title("SEIR epidemic on the Old Delhi street network (300 residents)")
    ax.grid(alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig(out, dpi=150)


if __name__ == "__main__":
    scen = HERE / "scenarios.csv"
    curves = HERE / "curves.csv"
    if scen.is_file():
        print(summarise(scen))
    if curves.is_file():
        plot_curves(curves, HERE.parent.parent / "docs" / "images" / "epidemic_curves.png")
        print("Saved docs/images/epidemic_curves.png")

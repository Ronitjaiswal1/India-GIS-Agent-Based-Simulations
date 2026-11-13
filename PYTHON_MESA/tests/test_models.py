"""Smoke tests: both Python models build and step without errors."""

import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def test_mesa_model_steps():
    import india_gis_model as m

    model = m.IndiaGISModel(width=80, height=60, num_people=50)
    for _ in range(5):
        model.step()
    assert len(model.people) == 50
    assert model.datacollector.get_model_vars_dataframe().shape[0] >= 5


def test_mesa_free_model_steps():
    import india_final_working as m

    model = m.IndiaGISModel(width=50, height=50, num_people=40)
    for _ in range(5):
        model.step()
    assert len(model.people_agents) == 40
    for person in model.people_agents:
        x, y = person.pos
        assert 0 <= x < 50 and 0 <= y < 50

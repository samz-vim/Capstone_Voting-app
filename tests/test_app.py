import pytest
from app import create_app, db


@pytest.fixture()
def client():
    app = create_app({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
    })
    with app.test_client() as client:
        yield client
    with app.app_context():
        db.session.remove()
        db.drop_all()


def test_home_page_loads(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"Bola Ahmed" in response.data
    assert b"Peter Obi" in response.data
    assert b"Atiku" in response.data


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_results_start_at_zero(client):
    response = client.get("/api/results")
    assert response.status_code == 200
    assert response.json["total_votes"] == 0
    assert len(response.json["candidates"]) == 3


@pytest.mark.parametrize("candidate_id", ["tinubu", "obi", "atiku"])
def test_valid_vote_is_recorded(client, candidate_id):
    response = client.post("/api/vote", json={"candidate_id": candidate_id})
    assert response.status_code == 201
    assert response.json["candidate_id"] == candidate_id


def test_invalid_candidate_is_rejected(client):
    response = client.post("/api/vote", json={"candidate_id": "not-a-candidate"})
    assert response.status_code == 400


def test_results_update_after_vote(client):
    client.post("/api/vote", json={"candidate_id": "obi"})
    response = client.get("/api/results")
    assert response.json["total_votes"] == 1
    obi = next(c for c in response.json["candidates"] if c["id"] == "obi")
    assert obi["votes"] == 1
    assert obi["percentage"] == 100

import os
from flask import Flask, jsonify, render_template, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func, text

db = SQLAlchemy()

CANDIDATES = {
    "tinubu": "Bola Ahmed Tinubu",
    "obi": "Peter Obi",
    "atiku": "Atiku Abubakar",
}


class Vote(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.String(20), nullable=False, index=True)


def create_app(test_config=None):
    app = Flask(__name__)
    app.config.update(
        SQLALCHEMY_DATABASE_URI=os.getenv(
            "DATABASE_URL",
            "postgresql+psycopg://voting:voting_dev_password@localhost:5432/voting",
        ),
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
        JSON_SORT_KEYS=False,
    )
    if test_config:
        app.config.update(test_config)

    db.init_app(app)

    # Starter-project convenience. For production, replace create_all with migrations.
    with app.app_context():
        db.create_all()

    @app.get("/")
    def index():
        return render_template("index.html", candidates=CANDIDATES)

    @app.get("/health")
    def health():
        try:
            db.session.execute(text("SELECT 1"))
            return jsonify(status="healthy", database="connected"), 200
        except Exception:
            db.session.rollback()
            app.logger.exception("Database health check failed")
            return jsonify(status="unhealthy", database="disconnected"), 503

    @app.post("/api/vote")
    def cast_vote():
        data = request.get_json(silent=True) or {}
        candidate_id = data.get("candidate_id")
        if candidate_id not in CANDIDATES:
            return jsonify(error="Select one of the three listed candidates."), 400
        db.session.add(Vote(candidate_id=candidate_id))
        db.session.commit()
        return jsonify(message="Demo vote recorded", candidate_id=candidate_id), 201

    @app.get("/api/results")
    def results():
        rows = db.session.query(
            Vote.candidate_id, func.count(Vote.id)
        ).group_by(Vote.candidate_id).all()
        totals = {candidate_id: 0 for candidate_id in CANDIDATES}
        for candidate_id, count in rows:
            if candidate_id in totals:
                totals[candidate_id] = count
        total_votes = sum(totals.values())
        candidates = [
            {
                "id": candidate_id,
                "name": name,
                "votes": totals[candidate_id],
                "percentage": round(totals[candidate_id] / total_votes * 100, 1)
                if total_votes else 0,
            }
            for candidate_id, name in CANDIDATES.items()
        ]
        candidates.sort(key=lambda item: item["votes"], reverse=True)
        return jsonify(total_votes=total_votes, candidates=candidates)

    return app


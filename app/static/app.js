const message = document.querySelector("#message");
const candidateIds = ["tinubu", "obi", "atiku"];
let refreshTimer;

function formatVotes(value) {
  return new Intl.NumberFormat().format(value);
}

async function loadResults() {
  try {
    const response = await fetch("/api/results", { cache: "no-store" });
    if (!response.ok) throw new Error("Could not load the latest results.");
    const data = await response.json();

    document.querySelector("#hero-total").textContent = formatVotes(data.total_votes);
    document.querySelector("#leader-summary").textContent = data.total_votes
      ? `${data.candidates[0].name} currently leads this demo count. Results are illustrative and update as votes are submitted.`
      : "No demo votes yet. Be the first to select a candidate.";

    for (const candidate of data.candidates) {
      const id = candidate.id;
      document.querySelector(`#${id}-percent`).textContent = `${candidate.percentage}%`;
      document.querySelector(`#${id}-votes`).textContent = formatVotes(candidate.votes);
      document.querySelector(`#${id}-bar`).style.width = `${candidate.percentage}%`;
    }

    document.querySelector("#results-list").innerHTML = data.candidates.map(candidate => `
      <div class="overall-row">
        <div class="overall-name">${escapeHtml(candidate.name)}</div>
        <div class="overall-track"><div class="overall-fill" style="width:${candidate.percentage}%"></div></div>
        <div class="overall-value">${candidate.percentage}% · ${formatVotes(candidate.votes)}</div>
      </div>
    `).join("");

    document.querySelector("#last-updated").textContent =
      new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  } catch (error) {
    message.textContent = error.message;
  }
}

function escapeHtml(value) {
  return value.replace(/[&<>"']/g, character => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;"
  })[character]);
}

async function castVote(candidateId, button) {
  button.disabled = true;
  message.textContent = "Recording your demo vote…";
  try {
    const response = await fetch("/api/vote", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ candidate_id: candidateId })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || "Vote could not be recorded.");
    message.textContent = `Your demo vote for ${candidateId === "tinubu" ? "Bola Ahmed Tinubu" : candidateId === "obi" ? "Peter Obi" : "Atiku Abubakar"} has been recorded.`;
    await loadResults();
  } catch (error) {
    message.textContent = error.message;
  } finally {
    button.disabled = false;
  }
}

document.querySelectorAll("[data-candidate]").forEach(button => {
  button.addEventListener("click", () => castVote(button.dataset.candidate, button));
});
document.querySelector("#refresh-button").addEventListener("click", loadResults);
loadResults();
refreshTimer = window.setInterval(loadResults, 5000);

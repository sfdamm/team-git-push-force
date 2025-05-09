# AI Event Concepter

### What is the main functionality?

An interactive **co-creation assistant** that turns a vague event idea into a polished concept—fast. The planner drags in any relevant documents (past reports, industry papers, brand decks). The AI digests that material, asks follow-up questions until all gaps are filled, and delivers a full concept package: theme, format, agenda outline, speaker & sponsor suggestions, and ticket-price ideas, exportable as PDF and JSON. Because the AI does the heavy lifting—researching, matching, structuring—it **cuts days of manual work to minutes**, keeps all context in one place, and lets the planner iterate (“add a workshop,” “make it hybrid”) with a single prompt.

---

### Who are the intended users?

* **Event-agency planners** who prepare multiple client proposals.
* **Corporate planners** who must respect internal policies yet still wow stakeholders.

---

### How will you integrate GenAI meaningfully?

* **LangChain + Weaviate RAG** over *user-supplied* documents—no external scraping—so every suggestion is grounded in the customer’s own industry context.
* **Adaptive dialogue** powered by an LLM that follows nine standard conception steps, probes for missing details, remembers answers, and supports unlimited refinements.
* **Creative synthesis** prompt chains craft themes, agendas, and curated speaker/sponsor lists that reflect both uploaded content and the evolving conversation.
* **Continuous learning**—each new debrief or guideline embedded today improves tomorrow’s concepts automatically.

---

### Describe some scenarios how your app will function

**Co-create a fresh pitch** – The planner uploads last year’s debrief and a market white paper, then says “Target 300 attendees, hybrid preferred.” The AI summarises the docs, asks two clarifiers (duration, networking preference), and returns a one-day concept. The planner adds, “Include a hands-on workshop and make the theme more visionary.” The AI revises the agenda and title, then offers a ready-to-share PDF.

**Compliance-aware brainstorm** – A corporate planner supplies the company’s policy handbook and audience personas. The AI filters speaker suggestions to fit policy, proposes an online format for global reach, and crafts sponsor packages aligned with brand guidelines. When the planner asks, “Shorten it to a half-day and add a panel,” the AI updates the concept instantly.

**Learning loop** – After an event, the planner uploads debrief notes (“need stronger networking, ticket price felt high”). Next time, the AI automatically proposes an interactive networking segment and adjusted ticket tiers, then asks, “Anything else you’d like to refine?”—keeping the focus on creative improvement instead of administrative grind.

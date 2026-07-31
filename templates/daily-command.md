Use skill `daily-workflow-orchestrator`.

Input:
- Work item: <issue URL or task description>
- Repository: <absolute path>
- Work type: task | bug | proposal
- Base branch: <branch>
- Browser writes: allowed | not allowed
- Push: allowed | not allowed
- PR creation: allowed | not allowed

Rules:
1. Run every required skill in order.
2. Do not edit code until readiness is PASS.
3. Use terminal for repository operations.
4. Use Browser MCP only after verification is PASS.
5. Store all evidence under `.my-ai/runs/<run-id>/`.
6. Never guess missing requirements.
7. Do not modify tests merely to make them pass.
8. Stop at any approval gate that is not explicitly granted.
9. End with the delivery report and workflow retrospective.
10. Return the final run status and evidence paths.


Additional mandatory rules:
11. For a feature or proposal, run `implementation-traceability` before planning or coding.
12. Every new function and business branch must cite its requirement, contract, existing pattern, invariant, and test.
13. For a bug, run `bug-history-root-cause` before coding.
14. Inspect git/task/PR history to identify whether the bug was introduced, exposed, or regressed by a prior change.
15. After fixing a bug, produce `root-cause-analysis.md` containing origin, root cause, solution, why the solution is correct, and regression evidence.


16. For bugs, distinguish symptom, proximate cause, contributing conditions,
    root cause, and systemic escape cause.
17. Do not change production code when only a proximate cause has been found.
18. Create and pass `.my-ai/runs/<run-id>/root-cause-gate.yaml` before fixing.
19. Consider competing hypotheses and run falsification tests.
20. A valid fix must prove removal of the root mechanism, not only disappearance
    of the visible symptom.


21. After finding the root cause, assess whether the correct solution exceeds the current ticket scope.
22. For cross-cutting or architectural fixes, stop the large patch and run `scope-escalation-and-decomposition`.
23. Raise a parent/systemic ticket and create bounded subtasks with owners, dependencies, acceptance criteria, tests, and evidence.
24. Do not mix broad refactoring with a small bug ticket.
25. Only implement a temporary mitigation in the current bug when explicitly allowed, and link it to the systemic-fix ticket.


26. When a correct fix affects multiple services/modules, list each affected component explicitly with repository, symbols/contracts, required changes, owner, dependencies, risks, and evidence.
27. Mark the run and issue `BLOCKED`, write the escalation report, optionally comment Jira, and stop.
28. Do not continue implementation merely because tickets or subtasks were created.
29. Resume only after an explicit unblock decision states the approved scope and authority.
30. After unblock, rerun readiness and scope gates before coding.

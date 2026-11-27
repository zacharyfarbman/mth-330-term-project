#set document(title: "Checkpoint 2 — Balancing Market Impact and Price Risk: Choosing a Trade Execution Horizon", author: ("Zachary Farbman", "Leineel Kristian Siquioco"))
#set page(paper: "us-letter", margin: 0.9in, numbering: "1")
#set text(font: "Libertinus Serif", size: 11.5pt)
#set par(justify: true, leading: 0.9em, spacing: 0.95em, first-line-indent: (amount: 1.25em, all: true))
#set heading(numbering: none)
#set list(indent: 0pt, body-indent: 1.15em, spacing: 0.75em)
#set terms(separator: [: ], hanging-indent: 1.25em, spacing: 0.7em)
#show list: set par(first-line-indent: 0pt)
#show terms: set par(first-line-indent: 0pt)
#show heading: set text(size: 12.5pt)
#show heading: set par(first-line-indent: 0pt)
#show heading: set block(above: 1.3em, below: 0.75em)
#show figure: set block(above: 1.1em, below: 1.1em)
#show table: set par(first-line-indent: 0pt, justify: false)
#let entry(body) = block(breakable: false, above: 0.85em, below: 0.85em)[
  #set par(first-line-indent: 0pt)
  #body
  #parbreak()
]

== 1. Group Members

#entry[Zachary Farbman and Leineel Kristian Siquioco]

== 2. Project Topic

#entry[
#set par(justify: false)
#text(size: 12.5pt, weight: "bold", hyphenate: false)[Balancing Market Impact and Price Risk: Choosing a Trade Execution Horizon]]

If we need to sell a fixed number of shares, should we sell quickly or spread the sale over time? Selling quickly can push down the price we receive, but selling slowly leaves more shares exposed to unpredictable price changes. We investigate this trade-off by assuming a constant selling rate and asking how long the sale should take.

This connects calculus to computing through a mathematical model, numerical checks, and graphs. Research by Almgren and Chriss helps us choose assumptions for representing the price effect and uncertainty. We study a simplified version, not a reproduction of their full solution.

== 3. Response to Checkpoint 1 Feedback

#entry[*Feedback:* _Compare equal percentage increases in volatility and risk aversion to show which has the larger effect on the preferred duration._]

Checkpoint 1 planned to vary σ and λ separately but did not say how the two effects would be compared. Raw changes cannot be compared directly, because σ and λ have different units. This checkpoint therefore raises each input by the *same percentage* while holding everything else fixed, and measures the resulting percentage change in the preferred duration $T^*$. Section 5 gives the exact answer, a derivative-based (elasticity) explanation, an illustrative table, and a graph. In short: *an equal percentage increase in volatility shortens the preferred duration about twice as much as the same increase in risk aversion.*

== 4. Model and Derivation

Let Q be the shares to sell, T the total sale duration in minutes, and t the time elapsed. Selling the same number of shares each minute gives, for $0 <= t <= T$,

$ v = Q/T, quad x(t) = Q(1 - t/T), $

where v is the selling rate and x(t) the shares still unsold. Assuming the per-share price disadvantage is proportional to selling speed with positive coefficient η gives a cost rate $eta v^2$. With arithmetic volatility σ (dollars per share per $sqrt("minute")$) and risk-aversion weight λ (1/dollar), the uncertainty-penalty rate is $lambda sigma^2 x(t)^2$. This penalizes variance, not expected loss.

Accumulating both rates over the sale, the cost-and-risk score in dollars is

$ J(T) = integral_0^T eta v^2 dif t + lambda sigma^2 integral_0^T x(t)^2 dif t = (eta Q^2) / T + (lambda sigma^2 Q^2 T) / 3. $

The first integral has a constant integrand, giving $eta (Q/T)^2 T$. For the second, $integral_0^T Q^2 (1 - t/T)^2 dif t = Q^2 T slash 3$: the area under the squared-inventory curve is one third of the rectangle $Q^2 T$. Both results were confirmed with SymPy.

*Limits and continuity.* J is continuous for $T > 0$, with $J -> infinity$ as $T -> 0^+$ (the impact term blows up) and as $T -> infinity$ (the risk term grows without bound). On a closed window $[T_("min"), T_("max")]$ with $T_("min") > 0$, the Extreme Value Theorem guarantees a minimum; T = 0 is never evaluated.

*Derivatives.* Setting the first derivative to zero,

$ J'(T) = -(eta Q^2) / T^2 + (lambda sigma^2 Q^2) / 3 = 0 quad => quad T^* = sqrt((3 eta) / (lambda sigma^2)). $

Since $J''(T) = 2 eta Q^2 slash T^3 > 0$ for all $T > 0$, J is concave up, so $T^*$ is the unique unrestricted minimum. If $T^*$ falls outside the allowed window, the best allowed duration is the nearer endpoint. Q cancels from $T^*$ under this model's scaling; we do not conclude that order size never matters in practice.

== 5. Comparing Equal Percentage Increases in σ and λ

*Exact comparison.* Raise one input by a fraction p (for example, p = 0.10 for 10%) and hold the others fixed. Substituting into $T^*$:

$ T^*_(sigma "up") = T^* / (1 + p), quad quad T^*_(lambda "up") = T^* / sqrt(1 + p). $

For every $p > 0$, $1 + p > sqrt(1 + p)$, so the volatility increase always produces the shorter duration. The reason is structural: σ enters the objective *squared*, through $lambda sigma^2$, while λ enters only to the first power.

*Elasticity (derivative) view.* The elasticity of $T^*$ with respect to an input measures the percentage change in $T^*$ per 1% change in that input:

$ (sigma / T^*) (partial T^*) / (partial sigma) = -1, quad quad (lambda / T^*) (partial T^*) / (partial lambda) = -1/2. $

So, for small changes, a 1% rise in volatility shortens the preferred duration by about 1%, while a 1% rise in risk aversion shortens it by only about 0.5%. Both elasticities are constant, so this two-to-one ratio holds at every baseline, not just the one chosen below.

*Equivalent increases.* Because only the product $lambda sigma^2$ matters, raising σ by a fraction p has exactly the same effect as raising λ by $(1+p)^2 - 1$. A 10% rise in volatility matches a 21% rise in risk aversion; a 50% rise in volatility matches a 125% rise.

*Illustrative numbers.* We use positive, illustrative inputs that are not fitted to market data: Q = 100,000 shares, $eta = 3 times 10^(-5)$ dollar·minute/share², $sigma = 0.05$ dollars/(share·$sqrt("minute")$), $lambda = 10^(-5)$ per dollar, and an allowed window of 5 to 240 minutes. The baseline preferred duration is $T^* = 60$ minutes, with $J(T^*) =$ \$10,000 split evenly between the impact and risk terms. Table 1 compares equal percentage increases; every value lies inside the window and matched a NumPy grid search to within 0.001 minutes.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (center, right, right, right, right),
    stroke: none,
    inset: (x: 8pt, y: 4.5pt),
    table.hline(stroke: 0.8pt),
    table.header(
      [*Increase*], [*$T^*$, σ raised*], [*Change*], [*$T^*$, λ raised*], [*Change*],
    ),
    table.hline(stroke: 0.5pt),
    [10%], [54.55 min], [−9.09%], [57.21 min], [−4.65%],
    [25%], [48.00 min], [−20.00%], [53.67 min], [−10.56%],
    [50%], [40.00 min], [−33.33%], [48.99 min], [−18.35%],
    [100%], [30.00 min], [−50.00%], [42.43 min], [−29.29%],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Preferred duration after raising one input by the stated percentage (baseline $T^* = 60$ min).],
)

#figure(
  image("checkpoint-2-sensitivity.svg", width: 88%),
  caption: [Preferred duration as each input is raised separately. The solid volatility curve falls faster than the dashed risk-aversion curve at every percentage.],
)

*Interpretation.* Doubling volatility halves the preferred duration, while doubling risk aversion shortens it by only about 29%. Higher volatility makes waiting more dangerous in two ways at once: each unsold share is exposed to larger price swings, and the variance penalty grows with the *square* of that scale. Higher risk aversion changes only how much we care about a fixed amount of variance. A trader who is unsure about both inputs should therefore estimate volatility most carefully, since errors in σ move the recommendation roughly twice as much.

*Limitation of the comparison.* The two-to-one ratio applies to the unrestricted optimum. If an increase pushes $T^*$ below $T_("min")$, the best allowed duration stays at the endpoint and further increases in either input have no effect, so the comparison can appear equal. In the final report we will show one baseline where this clipping occurs.

== 6. Mathematical and Python Methods

The accompanying script, `checkpoint-2-analysis.py`, uses SymPy to integrate the two rates, take limits at $0^+$ and $infinity$, differentiate, solve for $T^*$, and compute both elasticities and exact multipliers. NumPy then performs a grid search over the allowed window, endpoints included, to confirm each value in Table 1, and Matplotlib produces Figure 1. The final Jupyter notebook will extend this with graphs of both cost components, shares remaining, and $J(T)$ curves before and after each increase.

Any best duration applies only to a constant selling rate, not every possible pattern of sales. We continue to assume unchanged trading conditions and volatility, no underlying price trend, no lasting price effect from the sale, and complete selling without buying back shares. Closing prices alone cannot determine η or λ.

== 7. Plan for Meeting the Project Rubric

- *Problem Definition & Relevance (10%):* Start with the selling-speed dilemma and explain its computing connection.

- *Mathematical Modeling (15%):* Justify functions, assumptions, units, and the distinction between expected price cost and uncertainty.

- *Use of Calculus Concepts, CLO 1–5 (20%):* Use limits, continuity, first and second derivatives, and elasticities to locate and compare preferred durations.

- *Integration & Area Analysis, CLO 6–7 (10%):* Interpret the accumulated cost and the one-third area of the squared-inventory curve.

- *Python Implementation (15%):* Produce one clear, documented, reproducible notebook with symbolic and numerical checks.

- *Visualization & Interpretation (10%):* Label graphs clearly, including the equal-percentage comparison of σ and λ.

- *Analytical Insight & Discussion (10%):* Explain why volatility dominates risk aversion and where endpoint limits change that conclusion.

- *Report Organization & Presentation (5%):* Follow the question-to-model-to-method journey with consistent notation.

- *Creativity and Originality (5%):* Develop our own explanations and illustrative comparisons while crediting the underlying research.

== Glossary

/ Share: a unit of ownership in a company.

/ Trade execution: carrying out a purchase or sale; liquidation here means selling all the chosen shares.

/ Horizon: the duration allowed for that sale.

/ Constant-rate schedule: selling the same number of shares per unit of time.

/ Inventory: shares still unsold, represented by x(t).

/ Market impact: a price change caused by the trade itself.

/ Temporary impact: the immediate price disadvantage modeled during selling, rather than a lasting change.

/ Linear impact: assuming the per-share price disadvantage is proportional to selling speed.

/ Arithmetic price volatility (σ): the scale of random changes in dollar price per share; here measured per square root of a minute, not as a percentage.

/ Variance: expected squared deviation from the expected outcome, measuring uncertainty rather than average loss.

/ Price or timing risk: uncertainty in sale proceeds while waiting to sell.

/ Risk aversion (λ): preference for avoiding uncertainty.

/ Weighted variance or risk penalty: variance multiplied by λ to express that preference in the objective; it is a decision penalty, not predicted loss.

/ Objective J(T): the combined score we seek to minimize.

/ Preferred duration ($T^*$): the duration that minimizes J(T).

/ Parameter: a chosen model input, such as η, σ, or λ.

/ Sensitivity comparison: changing one input while holding others fixed to see how the answer changes.

/ Elasticity: the percentage change in an output per 1% change in an input, $(a slash f) dot (partial f slash partial a)$; it allows inputs with different units to be compared fairly.

/ Symbolic calculation: working with expressions exactly.

/ Numerical calculation: approximating answers using numbers.

== References:

#entry[Almgren, R., & Chriss, N. (December 2000 manuscript), #link("https://www.smallake.kr/wp-content/uploads/2016/03/optliq.pdf")[Optimal Execution of Portfolio Transactions], §§1.4–1.5, 2.2. Primary manuscript via third-party mirror; supports the general cost-and-variance framework, not our exact constant-rate horizon reduction.]

#entry[NYU (2013), #link("https://math.nyu.edu/inmemoriam/avellaneda/Project2.2013.pdf")[Risk and Portfolio Management], Assignment 2, Problems 1–2. Educational model treating time as continuously varying and holdings in dollars rather than shares; its coefficients will not be mixed with ours.]

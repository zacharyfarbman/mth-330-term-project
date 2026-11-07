#set document(title: "Balancing Market Impact and Price Risk: Choosing a Trade Execution Horizon", author: ("Zachary Farbman", "Leineel Kristian Siquioco"))
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

If we need to sell a fixed number of shares, should we sell quickly or spread the sale over time? Selling quickly can push down the price we receive, but selling slowly leaves more shares exposed to unpredictable price changes. We plan to investigate this trade-off by assuming a constant selling rate and asking how long the sale should take.

This connects calculus to computing through a mathematical model, numerical checks, and graphs. Research by Almgren and Chriss helps us choose assumptions for representing the price effect and uncertainty. We will study a simplified version, not reproduce their full solution.

== 3. Research Direction

First, let Q be the shares to sell, T the total sale duration in minutes, and t the time elapsed. If the same number of shares is sold each minute, v denotes that selling rate and x(t) the shares still unsold. We propose, for $0 <= t <= T$:

$ v = Q/T, quad x(t) = Q(1 - t/T). $

Next, we will describe two effects. For the expected price effect caused by our selling, assume the reduction in price per share is proportional to selling speed, with positive coefficient η. Selling v shares per minute then gives a cost rate $eta v^2$. Faster selling raises this cost rate.

For uncertainty, let σ be arithmetic price volatility: the scale of unpredictable price changes in dollar price per share, not percentage returns. Let λ be a positive weight expressing how strongly we wish to avoid uncertainty. Our model uses $lambda sigma^2 x(t)^2$ as an uncertainty-penalty rate: holding more unsold shares leaves more money exposed to price changes. This penalizes variance, a measure of spread around an expected outcome; it is not an expected loss.

We will use integrals to accumulate each rate over the sale, then combine them into J(T), a cost-and-risk score in dollars:

$ J(T) = integral_0^T eta v^2 dif t + lambda sigma^2 integral_0^T x(t)^2 dif t. $

Our intended next step is to derive and verify $J(T) = eta Q^2/T + lambda sigma^2 Q^2 T/3$ within this constant-rate model, not claim it as the researchers’ full solution. We will ask which allowed duration minimizes J, how that choice changes with σ, and how it changes with λ, varying each separately while fixing Q and η.

We will declare a shortest duration $T_("min")$ and longest duration $T_("max")$, with $0 < T_("min") < T_("max")$, and search between them, including both endpoints. Inputs will be positive, illustrative values, not values fitted to market data. With Q in shares and T in minutes, σ has units $"dollars"/("share" sqrt("minute"))$, η $"dollars" dot "minute"/"share"^2$, and λ 1/dollar.

We assume unchanged trading conditions and volatility, no underlying upward or downward price trend, no lasting price effect from the sale, and complete selling without buying back shares. We do not model reactions to changing prices or limits tied to overall market trading volume. Closing prices alone cannot determine η or λ.

== 4. Proposed Mathematical and Python Methods

We plan to integrate the two rates and explain their accumulated meanings. Continuity and limits will help us study J for positive durations, including its formal behavior near zero and at very large T. Continuity on our closed, positive time interval will support the existence of a minimum; we will never evaluate T = 0.

We will use the first derivative to find candidate durations and the second derivative to assess whether the unrestricted positive-duration minimum is unique. We will compare allowed candidates and endpoints. Changing σ and λ separately will explore the two remaining questions. Any best duration applies only to a constant selling rate, not every possible pattern of sales.

One future Jupyter notebook will use SymPy for exact symbolic integration, derivatives, and limits; NumPy for numerical comparisons; and Matplotlib for graphs of both cost components, shares remaining, and changes in the preferred duration. Optional SciPy tools can check integrals and search for a minimum. We will compare numerical answers with symbolic expressions and endpoint checks, document inputs, and explain graphs with units and labels.

These are proposed steps, not completed calculations, code, or conclusions. Methods may be refined. We will discuss simplifying assumptions, including why Q cancels from the preferred duration under this model’s scaling, rather than conclude that order size never matters in practice.

== 5. Plan for Meeting the Project Rubric

- *Problem Definition & Relevance (10%):* Start with the selling-speed dilemma and explain its computing connection.

- *Mathematical Modeling (15%):* Justify functions, assumptions, units, and the distinction between expected price cost and uncertainty.

- *Use of Calculus Concepts, CLO 1–5 (20%):* Explain limits, continuity, derivatives, and duration optimization with reasoning.

- *Integration & Area Analysis, CLO 6–7 (10%):* Interpret the accumulated cost and squared-unsold-shares exposure.

- *Python Implementation (15%):* Produce one clear, documented, reproducible notebook with symbolic and numerical checks.

- *Visualization & Interpretation (10%):* Label graphs clearly and explain what each comparison means.

- *Analytical Insight & Discussion (10%):* Interpret parameter effects and acknowledge where the simple model may fail.

- *Report Organization & Presentation (5%):* Follow the question-to-model-to-method journey with consistent notation.

- *Creativity and Originality (5%):* Develop our own explanations and illustrative comparisons while crediting the underlying research.

== Glossary

/ Share: a unit of ownership in a company.

/ Trade execution: carrying out a purchase or sale; liquidation here means selling all the chosen shares.

/ Horizon: the duration allowed for that sale.

/ Constant-rate schedule: selling the same number of shares per unit of time.

/ Inventory: shares still unsold, represented by x(t).

/ Piecewise model: separate rules for different time periods.

/ Market impact: a price change caused by the trade itself.

/ Temporary impact: the immediate price disadvantage modeled during selling, rather than a lasting change.

/ Linear impact: assuming the per-share price disadvantage is proportional to selling speed.

/ Arithmetic price volatility (σ): the scale of random changes in dollar price per share; here measured per square root of a minute, not as a percentage.

/ Variance: expected squared deviation from the expected outcome, measuring uncertainty rather than average loss.

/ Price or timing risk: uncertainty in sale proceeds while waiting to sell.

/ Risk aversion: preference for avoiding uncertainty.

/ Weighted variance or risk penalty: variance multiplied by λ to express that preference in the objective; it is a decision penalty, not predicted loss.

/ Objective J(T): the combined score we seek to minimize.

/ Parameter: a chosen model input, such as η, σ, or λ.

/ Sensitivity comparison: changing one input while holding others fixed to see how the answer changes.

/ Symbolic calculation: working with expressions exactly;

/ numerical calculation: approximating answers using numbers.

== References:

#entry[Almgren, R., & Chriss, N. (December 2000 manuscript), #link("https://www.smallake.kr/wp-content/uploads/2016/03/optliq.pdf")[Optimal Execution of Portfolio Transactions], §§1.4–1.5, 2.2. Primary manuscript via third-party mirror; supports the general cost-and-variance framework, not our exact constant-rate horizon reduction.]

#entry[NYU (2013), #link("https://math.nyu.edu/inmemoriam/avellaneda/Project2.2013.pdf")[Risk and Portfolio Management], Assignment 2, Problems 1–2. Educational model treating time as continuously varying and holdings in dollars rather than shares; its coefficients will not be mixed with ours.
]

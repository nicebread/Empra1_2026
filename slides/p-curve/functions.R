# ============================================================
# Density of p-values given statistical power
# ============================================================
# Theory:
#   For a z-test with non-centrality delta, the p-value
#   distribution under H1 depends on delta, which is derived
#   from the desired power and significance level.
#
#   One-sided:  p = 1 - Phi(Z),  Z ~ N(delta, 1)
#   Two-sided:  p = 2*(1 - Phi(|Z|)), |Z| ~ folded-N(delta, 1)
# ============================================================

#' Density of p-values under a given power
#'
#' @param p        Numeric vector of p-values in (0, 1).
#' @param power    Desired statistical power (1 - beta), in (0, 1).
#' @param sig.level Significance level alpha (default 0.05).
#' @param alternative "two.sided" (default) or "one.sided".
#' @param log      Logical; if TRUE, returns log-density.
#'
#' @return Numeric vector of density values (or log-densities).
#'
#' @examples
#' dpvalue(0.05, power = 0.80)
#' dpvalue(seq(0.001, 0.999, length.out = 500), power = 0.80)
dpvalue <- function(p,
                    power,
                    sig.level = 0.05,
                    alternative = c("two.sided", "one.sided"),
                    log = FALSE) {
  alternative <- match.arg(alternative)

  # --- Input validation ---
  stopifnot(
    is.numeric(p), all(p > 0 & p < 1),
    is.numeric(power), length(power) == 1, power > 0 & power < 1,
    is.numeric(sig.level), length(sig.level) == 1, sig.level > 0 & sig.level < 1
  )

  # --- Recover non-centrality parameter delta from power ---
  delta <- .solve_delta(power, sig.level, alternative)

  # --- Compute density ---
  if (alternative == "one.sided") {
    # p = 1 - Phi(Z)  =>  Z = qnorm(1 - p)
    # f(p) = phi(Z - delta) / phi(Z)
    z <- qnorm(1 - p)
    ld <- dnorm(z - delta, log = TRUE) - dnorm(z, log = TRUE)
  } else {
    # p = 2*(1 - Phi(|Z|))  =>  |Z| = qnorm(1 - p/2)
    # f(p) = [phi(q - delta) + phi(q + delta)] / (2 * phi(q))
    q <- qnorm(1 - p / 2)
    ld <- log(dnorm(q - delta) + dnorm(q + delta)) -
      log(2) - dnorm(q, log = TRUE)
  }

  if (log) ld else exp(ld)
}


#' Solve for non-centrality parameter (delta) given statistical power
#'
#' This internal helper function calculates the non-centrality parameter
#' required to achieve a specific statistical power for a given significance level.
#'
#' @param power Numeric. Desired statistical power (1 - beta), in (0, 1).
#' @param sig.level Numeric. Significance level alpha.
#' @param alternative Character. "two.sided" or "one.sided".
#'
#' @return Numeric. The calculated non-centrality parameter (delta).
#' @keywords internal
.solve_delta <- function(power, sig.level, alternative) {
  z_a <- qnorm(1 - sig.level)
  z_a2 <- qnorm(1 - sig.level / 2)

  if (alternative == "one.sided") {
    z_a + qnorm(power) # closed form
  } else {
    # Power = P(Z > z_{a/2} - d) + P(Z < -z_{a/2} - d)
    # is symmetric in d and → 1 at BOTH ±Inf.
    # The unique root for power > alpha lives on (0, +Inf).
    power_fn <- function(d) {
      pnorm(z_a2 - d, lower.tail = FALSE) +
        pnorm(-z_a2 - d) - power
    }

    # At d=0: power_fn = alpha - power < 0  (since power > alpha)
    # At d=upper: power_fn → 1 - power > 0
    upper <- z_a2 + qnorm(power) + 10 # generous upper bound

    uniroot(power_fn, interval = c(0, upper), tol = 1e-10)$root
  }
}


#' Plot the expected p-value distribution under the null hypothesis (H0)
#'
#' This function generates a ggplot showing a uniform density distribution
#' of p-values, which is expected when there is no true effect (H0).
#'
#' @param stage Integer (1, 2, or 3) indicating the plot depth:
#'   1: Base H0 line and dotted borders.
#'   2: Adds the light red background area.
#'   3: Adds the 5% significance region, text labels, and dart images. 
#'      Note: Dart images are searched relative to the path of the Quarto 
#'      file calling this function.
#'
#' @return A ggplot object representing the H0 distribution.
#' @export
#'
#' @examples
#' plot_h0(stage = 1)
#' plot_h0(stage = 3)
plot_h0 <- function(stage = 1) {
  p <- ggplot()

  # Stage 2 & 3: Light red background area
  if (stage >= 2) {
    p <- p + annotate("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1, fill = "#FCD9D9")
  }

  # Stage 3: Dark red significance box and text labels
  if (stage >= 3) {
    p <- p + 
      annotate("rect", xmin = 0, xmax = 0.05, ymin = 0, ymax = 1, fill = "firebrick") +
      annotate("text", x = 0.025, y = 0.5, label = "5%", color = "white", 
               fontface = "bold", angle = 90, size = 6)
  }

  # Stage 1: Base lines (always present)
  p <- p +
    geom_segment(aes(x = 0, xend = 0, y = 0, yend = 1), linetype = "dotted") +
    geom_segment(aes(x = 1, xend = 1, y = 0, yend = 1), linetype = "dotted") +
    geom_segment(aes(x = 0, xend = 1, y = 0, yend = 0), linetype = "dotted") +
    geom_segment(aes(x = 0, xend = 1, y = 1, yend = 1), color = "red", linewidth = 1.2) +
    scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.2), 
                       labels = function(x) sprintf("%.1f", x)) +
    scale_y_continuous(limits = c(0, 5)) +
    labs(x = "p value", y = "Density") +
    guides(x = guide_axis(cap = "both"), y = guide_axis(cap = "both")) +
    theme_classic(base_size = 14)

  # Stage 3: Dart symbols (On top of Stage 1 lines)
  if (stage >= 3) {
    dart_data <- data.frame(
      x = c(0.09, 0.29, 0.50, 0.58, 0.74, 0.89),
      y = c(1.05, 1.05, 1.05, 1.05, 1.05, 1.05),
      image = "img/dart.png"
    )

    p <- p + 
      ggimage::geom_image(
        data = dart_data,
        mapping = aes(x = x, y = y, image = image),
        inherit.aes = FALSE,
        asp = 1,
        size = 0.25
      )
  }

  return(p)
}

#' Plot the expected p-value distribution under the alternative hypothesis (H1)
#'
#' This function visualizes the right-skewed p-value distribution (p-curve)
#' expected when a true effect exists, given a specific statistical power.
#'
#' @param power Numeric. The true statistical power (1 - beta). Default is 0.10.
#' @param p.max Numeric. The maximum p-value to plot on the x-axis. Default is 0.9999.
#' @param ymax Numeric. The maximum y-axis value (density). Default is 5.
#' @param sig.region Logical. If TRUE, visually highlights the significant region (p <= 0.05).
#' @param label Character. Optional custom text for the blue box. Use \n for line breaks.
#'
#' @return A ggplot object representing the p-curve.
#' @export
#'
#' @examples
#' pcurve_plot(.80, ymax = 30, sig.region = TRUE)
pcurve_plot <- function(power = .10, p.max = .9999, ymax = 5, sig.region = FALSE, label = NULL) {
    # Generate data for the curve
    df <- data.frame(p = seq(.001, p.max, length.out = 1000))
    df$density <- dpvalue(df$p, power = power)

    # Base plot with area and H0 reference line
    p_base <- ggplot(df, aes(x = p, y = density)) +
        geom_area(fill = "#DFFABE", color = "black", linetype = "dotted", 
                  linewidth = 0.5, outline.type = "full") +
        geom_line(color = "green", linewidth = 1.2) +
        annotate("segment", x = 0.01, xend = p.max, y = 1, yend = 1, 
                 color = "red", linetype = "dashed", linewidth = 0.8) +
        scale_x_continuous(limits = c(0, round(p.max, 1)), breaks = seq(0, 1, by = 0.2), 
                           labels = function(x) sprintf("%.1f", x)) +
        scale_y_continuous(limits = c(0, ymax)) +
        labs(x = "p value", y = "Density") +
        guides(x = guide_axis(cap = "both"), y = guide_axis(cap = "both")) +
        theme_classic(base_size = 14)

    # Add significance region and blue callout bubble
    if (sig.region) {
        df_sig <- df[df$p <= 0.05, ]

        # Determine final label text
        # If label is NULL, use default percentage, otherwise use provided label
        final_label <- if (is.null(label)) paste(round(power * 100), "% power") else label

        p_base <- p_base +
            geom_area(data = df_sig, fill = "#93F759", color = "black", 
                      linetype = "dotted", linewidth = 0.5, outline.type = "full") +
            # Vertical percentage text inside the green box
            annotate("text",
                x = 0.025, y = 0,
                label = paste0(round(power * 100), "%"),
                color = "black", fontface = "bold", angle = 90, hjust = -0.1, size = 6
            ) +
            # Blue Callout: Pointer/Line
            annotate("segment", 
                     x = 0.4, y = ymax * 0.7, 
                     xend = 0.05, yend = dpvalue(0.05, power = power), 
                     color = "royalblue", linewidth = 2.5) +
            # Blue Callout: Label Box
            annotate("label", 
                     x = 0.4, y = ymax * 0.7, 
                     label = final_label, 
                     fill = "royalblue", color = "white", 
                     fontface = "bold", 
                     size = 8,
                     hjust = 0, 
                     vjust = 0, 
                     label.padding = unit(0.8, "lines"), 
                     label.size = NA)
    }

    return(p_base)
}

#' Special P-Curve Plot 2: Highlight specific p-value bins
#'
#' This function creates a detailed view of the p-curve for small p-values
#' (e.g., up to 0.20), specifically highlighting the regions 0 to 0.025 and
#' 0.025 to 0.05 with distinct colors.
#'
#' @param power Numeric. The true statistical power. Default is 0.60.
#' @param p.max Numeric. The maximum p-value to plot. Default is 0.2.
#' @param ymax Numeric. The maximum density on the y-axis. Default is 50.
#'
#' @return A ggplot object showing binned significance regions.
#' @export
#'
#' @examples
#' plot_special_2()
plot_special_2 <- function(power = .60, p.max = 0.2, ymax = 50) {
    df <- data.frame(p = seq(.001, p.max, length.out = 1000))
    df$density <- dpvalue(df$p, power = power)

    df_sig1 <- df[df$p >= 0.025 & df$p <= 0.05, ]
    df_sig2 <- df[df$p <= 0.025, ]

    p <- ggplot(df, aes(x = p, y = density)) +
        geom_area(fill = "#FC8C6C") +
        geom_area(data = df_sig1, fill = "#FAC12A") +
        geom_area(data = df_sig2, fill = "#83F41F") +
        geom_line(color = "grey20", linewidth = 0.8) +
        scale_x_continuous(limits = c(0, round(p.max, 1)), breaks = seq(0, p.max, by = 0.05), labels = function(x) sprintf("%.2f", x)) +
        scale_y_continuous(limits = c(0, ymax)) +
        labs(x = "p value", y = "Density") +
        guides(x = guide_axis(cap = "both"), y = guide_axis(cap = "both")) +
        theme_classic(base_size = 14)
    return(p)
}

import 'package:flutter/material.dart';

/// A centralized theme/style configuration for all `pagination_advanced` widgets.
///
/// Instead of passing individual color and style parameters to every widget,
/// you can configure a [PaginationTheme] once and pass it to the widget.
/// Per-prop values always take precedence over values defined in the theme.
///
/// ### Example
/// ```dart
/// PaginatedListView<Product>(
///   fetch: api.getProducts,
///   theme: PaginationTheme(
///     shimmerBaseColor: Colors.grey.shade300,
///     shimmerHighlightColor: Colors.grey.shade100,
///     refreshIndicatorColor: Colors.deepPurple,
///     errorTextStyle: TextStyle(color: Colors.red),
///     retryButtonStyle: ElevatedButton.styleFrom(
///       backgroundColor: Colors.deepPurple,
///     ),
///   ),
///   itemBuilder: (context, item) => ProductCard(item),
/// )
/// ```
class PaginationTheme {
  // ── Shimmer ────────────────────────────────────────────────────────────────

  /// The base (dark) color of the shimmer animation.
  final Color shimmerBaseColor;

  /// The highlight (light) color of the shimmer animation.
  final Color shimmerHighlightColor;

  // ── Refresh indicator ──────────────────────────────────────────────────────

  /// The color of the spinning [RefreshIndicator] arrow.
  final Color? refreshIndicatorColor;

  /// The background color of the [RefreshIndicator] circle.
  final Color? refreshBackgroundColor;

  // ── Error state ────────────────────────────────────────────────────────────

  /// Text style for the error message.
  final TextStyle? errorTextStyle;

  /// Button style for the retry button shown on error.
  final ButtonStyle? retryButtonStyle;

  /// Label for the retry button. Defaults to "Retry".
  final String retryLabel;

  // ── Empty state ────────────────────────────────────────────────────────────

  /// Text style for the empty-state message.
  final TextStyle? emptyTextStyle;

  /// The default message shown when the list is empty and no [emptyBuilder] is
  /// provided.
  final String emptyLabel;

  // ── End of list ────────────────────────────────────────────────────────────

  /// Text style for the end-of-list message.
  final TextStyle? endOfListTextStyle;

  /// Message shown at the bottom of the list when there are no more items.
  /// Defaults to "You've reached the end.".
  final String endOfListLabel;

  const PaginationTheme({
    this.shimmerBaseColor = const Color(0xFFE0E0E0),
    this.shimmerHighlightColor = const Color(0xFFF5F5F5),
    this.refreshIndicatorColor,
    this.refreshBackgroundColor,
    this.errorTextStyle,
    this.retryButtonStyle,
    this.retryLabel = 'Retry',
    this.emptyTextStyle,
    this.emptyLabel = 'No items found.',
    this.endOfListTextStyle,
    this.endOfListLabel = "You've reached the end.",
  });

  /// Creates a copy of this theme with certain fields replaced.
  PaginationTheme copyWith({
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    Color? refreshIndicatorColor,
    Color? refreshBackgroundColor,
    TextStyle? errorTextStyle,
    ButtonStyle? retryButtonStyle,
    String? retryLabel,
    TextStyle? emptyTextStyle,
    String? emptyLabel,
    TextStyle? endOfListTextStyle,
    String? endOfListLabel,
  }) {
    return PaginationTheme(
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      refreshIndicatorColor:
          refreshIndicatorColor ?? this.refreshIndicatorColor,
      refreshBackgroundColor:
          refreshBackgroundColor ?? this.refreshBackgroundColor,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      retryButtonStyle: retryButtonStyle ?? this.retryButtonStyle,
      retryLabel: retryLabel ?? this.retryLabel,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      emptyLabel: emptyLabel ?? this.emptyLabel,
      endOfListTextStyle: endOfListTextStyle ?? this.endOfListTextStyle,
      endOfListLabel: endOfListLabel ?? this.endOfListLabel,
    );
  }
}

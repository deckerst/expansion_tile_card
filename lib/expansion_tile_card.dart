library expansion_tile_card;

// Originally based on ExpansionTile from Flutter.
//
// Copyright 2014 The Flutter Authors. All rights reserved.
// Copyright 2020 Kyle Bradshaw. All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [child].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [ExpansionTileCard] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile children when the
///    expansion tile represents a sublist.
///  * [ExpansionTile], the original widget on which this widget is based.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class ExpansionTileCard extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [child]. The [initiallyExpanded] property must
  /// be non-null.
  ExpansionTileCard({
    Key? key,
    this.value = '',
    ValueNotifier<String?>? expandedNotifier,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    required this.child,
    this.trailing,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 2.0,
    this.initialElevation = 0.0,
    this.expandable = true,
    this.initiallyExpanded = false,
    this.initialPadding = EdgeInsets.zero,
    this.finalPadding = const EdgeInsets.only(bottom: 6.0),
    this.contentPadding,
    this.baseColor,
    this.expandedColor,
    this.expandedTextColor,
    this.duration = const Duration(milliseconds: 200),
    this.elevationCurve = Curves.easeOut,
    this.heightFactorCurve = Curves.easeIn,
    this.turnsCurve = Curves.easeIn,
    this.colorCurve = Curves.easeIn,
    this.paddingCurve = Curves.easeIn,
    this.isThreeLine = false,
    this.shadowColor = const Color(0xffaaaaaa),
    this.animateTrailing = false,
  })  : this.expandedNotifier = expandedNotifier ?? ValueNotifier(null),
        super(key: key);

  final String value;

  final ValueNotifier<String?> expandedNotifier;

  final bool isThreeLine;

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widget that is displayed when the tile expands.
  final Widget child;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Whether or not to animate a custom trailing widget.
  ///
  /// Defaults to false.
  final bool animateTrailing;

  /// The radius used for the Material widget's border. Only visible once expanded.
  ///
  /// Defaults to a circular border with a radius of 8.0.
  final BorderRadiusGeometry borderRadius;

  /// The final elevation of the Material widget, once expanded.
  ///
  /// Defaults to 2.0.
  final double elevation;

  /// The elevation when collapsed
  ///
  /// Defaults to 0.0
  final double initialElevation;

  final bool expandable;

  /// The color of the cards shadow.
  ///
  /// Defaults to Color(0xffaaaaaa)
  final Color shadowColor;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// The padding around the outside of the ExpansionTileCard while collapsed.
  ///
  /// Defaults to EdgeInsets.zero.
  final EdgeInsetsGeometry initialPadding;

  /// The padding around the outside of the ExpansionTileCard while collapsed.
  ///
  /// Defaults to 6.0 vertical padding.
  final EdgeInsetsGeometry finalPadding;

  /// The inner `contentPadding` of the ListTile widget.
  ///
  /// If null, ListTile defaults to 16.0 horizontal padding.
  final EdgeInsetsGeometry? contentPadding;

  /// The background color of the unexpanded tile.
  ///
  /// If null, defaults to Theme.of(context).canvasColor.
  final Color? baseColor;

  /// The background color of the expanded card.
  ///
  /// If null, defaults to Theme.of(context).cardColor.
  final Color? expandedColor;

  ///The color of the text of the expended card
  ///
  ///If null, defaults to Theme.of(context).accentColor.
  final Color? expandedTextColor;

  /// The duration of the expand and collapse animations.
  ///
  /// Defaults to 200 milliseconds.
  final Duration duration;

  /// The animation curve used to control the elevation of the expanded card.
  ///
  /// Defaults to Curves.easeOut.
  final Curve elevationCurve;

  /// The animation curve used to control the height of the expanding/collapsing card.
  ///
  /// Defaults to Curves.easeIn.
  final Curve heightFactorCurve;

  /// The animation curve used to control the rotation of the `trailing` widget.
  ///
  /// Defaults to Curves.easeIn.
  final Curve turnsCurve;

  /// The animation curve used to control the header, icon, and material colors.
  ///
  /// Defaults to Curves.easeIn.
  final Curve colorCurve;

  /// The animation curve used by the expanding/collapsing padding.
  ///
  /// Defaults to Curves.easeIn.
  final Curve paddingCurve;

  @override
  ExpansionTileCardState createState() => ExpansionTileCardState();
}

class ExpansionTileCardState extends State<ExpansionTileCard> with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _materialColorTween = ColorTween();
  late EdgeInsetsTween _edgeInsetsTween;
  late Animatable<double> _elevationTween;
  late Animatable<double> _heightFactorTween;
  late Animatable<double> _turnsTween;
  late Animatable<double> _colorTween;
  late Animatable<double> _paddingTween;

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<double> _elevation;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _materialColor;
  late Animation<EdgeInsets> _padding;

  bool get _isExpanded => widget.expandedNotifier.value == widget.value;

  @override
  void initState() {
    super.initState();
    _edgeInsetsTween = EdgeInsetsTween(
      begin: widget.initialPadding as EdgeInsets?,
      end: widget.finalPadding as EdgeInsets?,
    );
    _elevationTween = CurveTween(curve: widget.elevationCurve);
    _heightFactorTween = CurveTween(curve: widget.heightFactorCurve);
    _colorTween = CurveTween(curve: widget.colorCurve);
    _turnsTween = CurveTween(curve: widget.turnsCurve);
    _paddingTween = CurveTween(curve: widget.paddingCurve);

    _controller = AnimationController(duration: widget.duration, vsync: this);
    _heightFactor = _controller.drive(_heightFactorTween);
    _iconTurns = _controller.drive(_halfTween.chain(_turnsTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_colorTween));
    _materialColor = _controller.drive(_materialColorTween.chain(_colorTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_colorTween));
    _elevation = _controller.drive(Tween<double>(begin: widget.initialElevation, end: widget.elevation).chain(_elevationTween));
    _padding = _controller.drive(_edgeInsetsTween.chain(_paddingTween));
    if (PageStorage.of(context)?.readState(context) as bool? ?? widget.initiallyExpanded) {
      widget.expandedNotifier.value = widget.value;
      _controller.value = 1.0;
    }
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(ExpansionTileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(ExpansionTileCard widget) {
    widget.expandedNotifier.addListener(_onExpansionChanged);
  }

  void _unregisterWidget(ExpansionTileCard widget) {
    widget.expandedNotifier.removeListener(_onExpansionChanged);
  }

  void _onExpansionChanged() {
    setState(() {
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.child.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  void expand() {
    widget.expandedNotifier.value = widget.value;
  }

  void collapse() {
    widget.expandedNotifier.value = null;
  }

  void toggleExpansion() {
    _isExpanded ? collapse() : expand();
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Padding(
      padding: _padding.value,
      child: Material(
        type: MaterialType.card,
        color: _materialColor.value,
        borderRadius: widget.borderRadius,
        elevation: _elevation.value,
        shadowColor: widget.shadowColor,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                customBorder: RoundedRectangleBorder(borderRadius: widget.borderRadius),
                onTap: widget.expandable ? toggleExpansion : null,
                child: ListTileTheme.merge(
                  iconColor: _iconColor.value,
                  textColor: _headerColor.value,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      isThreeLine: widget.isThreeLine,
                      contentPadding: widget.contentPadding,
                      leading: widget.leading,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      trailing: widget.expandable
                          ? RotationTransition(
                              turns: widget.trailing == null || widget.animateTrailing ? _iconTurns : AlwaysStoppedAnimation(0),
                              child: widget.trailing ?? Icon(Icons.expand_more),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (child != null)
                ClipRect(
                  child: Align(
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _headerColorTween
      ..begin = theme.textTheme.subtitle1!.color
      ..end = widget.expandedTextColor ?? theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = widget.expandedTextColor ?? theme.accentColor;
    _materialColorTween
      ..begin = widget.baseColor ?? theme.canvasColor
      ..end = widget.expandedColor ?? theme.cardColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : widget.child,
    );
  }
}

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
    Key key,
    this.value = '',
    ValueNotifier<String> expandedNotifier,
    this.leading,
    @required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.child,
    this.trailing,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 2.0,
    this.expandable = true,
    this.initiallyExpanded = false,
    this.initialPadding = EdgeInsets.zero,
    this.finalPadding = const EdgeInsets.symmetric(vertical: 6.0),
    this.contentPadding,
    this.baseColor,
    this.expandedColor,
    this.duration = const Duration(milliseconds: 200),
    this.elevationCurve = Curves.easeOut,
    this.heightFactorCurve = Curves.easeIn,
    this.turnsCurve = Curves.easeIn,
    this.colorCurve = Curves.easeIn,
    this.paddingCurve = Curves.easeIn,
  })  : assert(initiallyExpanded != null),
        this.expandedNotifier = expandedNotifier ?? ValueNotifier(null),
        super(key: key);

  final String value;

  final ValueNotifier<String> expandedNotifier;

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget subtitle;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The widget that is displayed when the tile expands.
  final Widget child;

  /// A widget to display instead of a rotating arrow icon.
  final Widget trailing;

  /// The radius used for the Material widget's border. Only visible once expanded.
  ///
  /// Defaults to a circular border with a radius of 8.0.
  final BorderRadiusGeometry borderRadius;

  /// The final elevation of the Material widget, once expanded.
  ///
  /// Defaults to 2.0.
  final double elevation;

  final bool expandable;

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
  final EdgeInsetsGeometry contentPadding;

  /// The background color of the unexpanded tile.
  ///
  /// If null, defaults to Theme.of(context).canvasColor.
  final Color baseColor;

  /// The background color of the expanded card.
  ///
  /// If null, defaults to Theme.of(context).cardColor.
  final Color expandedColor;

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
  _ExpansionTileCardState createState() => _ExpansionTileCardState();
}

class _ExpansionTileCardState extends State<ExpansionTileCard> with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _materialColorTween = ColorTween();
  EdgeInsetsTween _edgeInsetsTween;
  Animatable<double> _elevationTween;
  Animatable<double> _heightFactorTween;
  Animatable<double> _turnsTween;
  Animatable<double> _colorTween;
  Animatable<double> _paddingTween;

  AnimationController _controller;
  Animation<double> _iconTurns;
  Animation<double> _heightFactor;
  Animation<double> _elevation;
  Animation<Color> _headerColor;
  Animation<Color> _iconColor;
  Animation<Color> _materialColor;
  Animation<EdgeInsets> _padding;

  bool get _isExpanded => widget.expandedNotifier.value == widget.value;

  @override
  void initState() {
    super.initState();
    _edgeInsetsTween = EdgeInsetsTween(
      begin: widget.initialPadding,
      end: widget.finalPadding,
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
    _elevation = _controller.drive(Tween<double>(begin: 0.0, end: widget.elevation).chain(_elevationTween));
    _padding = _controller.drive(_edgeInsetsTween.chain(_paddingTween));
    if (PageStorage.of(context)?.readState(context) as bool ?? widget.initiallyExpanded) {
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

  void _handleTap() => widget.expandedNotifier.value = _isExpanded ? null : widget.value;

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

  Widget _buildChildren(BuildContext context, Widget child) {
    return Padding(
      padding: _padding.value,
      child: Material(
        type: MaterialType.card,
        color: _materialColor.value,
        borderRadius: widget.borderRadius,
        elevation: _elevation.value,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                customBorder: RoundedRectangleBorder(borderRadius: widget.borderRadius),
                onTap: widget.expandable ? _handleTap : null,
                child: ListTileTheme.merge(
                  iconColor: _iconColor.value,
                  textColor: _headerColor.value,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      contentPadding: widget.contentPadding,
                      leading: widget.leading,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      trailing: widget.expandable
                          ? widget.trailing ??
                              RotationTransition(
                                turns: _iconTurns,
                                child: const Icon(Icons.expand_more),
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
      ..begin = theme.textTheme.subtitle1.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
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

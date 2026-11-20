import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';

/// A record ID, folio, RFC or UUID set in the mono `recordId` role (spec 077
/// FR-019), so every screen shows identifiers the same way.
///
/// It styles text; it does not decide what the text is. Each screen keeps its
/// own rule for the value (a serial, a `#id`, a localized draft folio) and
/// passes the finished string. Not for product codes, which stay in body text
/// (spec 022 FR-028), nor for amounts.
class RecordIdText extends StatelessWidget {
  const RecordIdText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;

  /// Overrides the inherited text color (e.g. a muted ID next to a name).
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).typeRoles.recordId;
    return Text(
      text,
      style: color == null ? style : style.copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';

class ReceiveAmountField extends StatefulWidget {
  @override
  _ReceiveAmountFieldState createState() => _ReceiveAmountFieldState();
}

class _ReceiveAmountFieldState extends State<ReceiveAmountField> {
  final _ctrl = TextEditingControllerWorkaroud();

  @override
  void initState() {
    super.initState();

    _ctrl.addListener(_onFieldChange);
    swapBloc.outAmountReceive.listen(_onDataChange);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _onDataChange(swapBloc.amountReceive));
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        key: Key('input-text-buy'),
        scrollPadding: const EdgeInsets.only(left: 35),
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: appConfig.tradeFormPrecision),
          FilteringTextInputFormatter.allow(RegExp(
              '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
        ],
        controller: _ctrl,
        enabled: swapBloc.enabledReceiveField,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.subtitle2,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).accentColor),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
        ));
  }

  void _onFieldChange() {
    tradeForm.onReceiveAmountFieldChange(_ctrl.text);
  }

  void _onDataChange(Rational value) {
    if (!mounted) return;
    if (value == null) {
      _ctrl.text = '';
      return;
    }

    final String newFormatted =
        cutTrailingZeros(value.toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_ctrl.text);

    if (newFormatted != currentFormatted) {
      _ctrl.setTextAndPosition(newFormatted);
    }
  }
}
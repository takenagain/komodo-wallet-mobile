import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:provider/provider.dart';

void showCurrenciesDialog(BuildContext context) {
  final CexProvider cexProvider =
      Provider.of<CexProvider>(context, listen: false);
  final String current = cexProvider.selectedFiat;
  final List<String> available = cexProvider.fiatList;
  if (available == null || available.isEmpty) return;

  const List<String> primary = ['USD', 'EUR', 'GBP', 'CNY', 'RUB', 'TRY'];

  final List<String> sorted = List.from(available);
  sorted.sort((String a, String b) {
    for (String curr in primary) {
      if (a == curr && b != curr) return -1;
      if (b == curr && a != curr) return 1;
    }

    return a.compareTo(b);
  });

  final List<Widget> options = [];
  for (String currency in sorted) {
    Image flag;
    try {
      flag = Image.asset('assets/currency-flags/${currency.toLowerCase()}.png');
    } catch (_) {}

    options.add(SimpleDialogOption(
      onPressed: () {
        cexProvider.selectedFiat = currency;
        dialogBloc.closeDialog(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          currency == current
              ? Icon(
                  Icons.radio_button_checked,
                  color: Theme.of(context).accentColor,
                  size: 14,
                )
              : Icon(Icons.radio_button_unchecked, size: 14),
          if (flag != null)
            Row(
              children: <Widget>[
                const SizedBox(width: 8),
                SizedBox(
                  width: 18,
                  child: flag,
                ),
              ],
            ),
          const SizedBox(width: 8),
          Text(
            currency,
            style: TextStyle(
              color: currency == current ? Theme.of(context).accentColor : null,
            ),
          ),
        ],
      ),
    ));
  }

  dialogBloc.dialog = showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Currency'), // TODO(yurii): localization
          contentPadding: const EdgeInsets.only(
            bottom: 20,
          ),
          titlePadding: const EdgeInsets.all(20),
          children: <Widget>[
            ...options,
          ],
        );
      });
}
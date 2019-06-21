import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page.dart';

class SwapHistory extends StatefulWidget {
  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  int limit = 50;
  String fromUUID;
  ScrollController _scrollController = new ScrollController();
  bool isLoadingNewSwaps = false;

  @override
  void initState() {
    swapHistoryBloc.updateSwaps(50, null);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadingNewSwaps = true;
        });
        swapHistoryBloc.updateSwaps(limit, fromUUID).then((onValue) {
          setState(() {
            isLoadingNewSwaps = false;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapHistoryBloc.swaps,
        builder: (context, snapshot) {
          print(snapshot.data.length);
          print(snapshot.connectionState);
          List<Swap> swaps = snapshot.data;

          swaps.removeWhere((swap) =>
                swap.status != Status.SWAP_SUCCESSFUL &&
                swap.status != Status.TIME_OUT);
          if (snapshot.hasData &&
              swaps.length == 0 &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.body2,
              ),
            );
          } else if (snapshot.hasData && swaps.length > 0) {


            swaps.sort((b, a) {
              if (b is Swap && a is Swap) {
                if (a.result.myInfo.startedAt != null) {
                  return a.result.myInfo.startedAt
                      .compareTo(b.result.myInfo.startedAt);
                }
              }
            });

            List<Widget> swapsWidget = swaps
                .map((swap) => BuildItemSwap(context: context, swap: swap))
                .toList();

            return RefreshIndicator(
              backgroundColor: Theme.of(context).backgroundColor,
              onRefresh: _onRefresh,
              child: ListView(
                padding: EdgeInsets.all(8),
                controller: _scrollController,
                children: swapsWidget,
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<List<Swap>> _onRefresh() async {
    return await swapHistoryBloc.updateSwaps(limit, null);
  }
}

class BuildItemSwap extends StatefulWidget {
  final BuildContext context;
  final Swap swap;

  BuildItemSwap({this.context, this.swap});

  @override
  _BuildItemSwapState createState() => _BuildItemSwapState();
}

class _BuildItemSwapState extends State<BuildItemSwap> {
  @override
  Widget build(BuildContext context) {
    String swapStatus =
        swapHistoryBloc.getSwapStatusString(context, widget.swap.status);
    Color colorStatus = swapHistoryBloc.getColorStatus(widget.swap.status);
    String stepStatus = swapHistoryBloc.getStepStatus(widget.swap.status);

    return Card(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SwapDetailPage(
                        swap: widget.swap,
                      )),
            );
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildTextAmount(widget.swap.result.myInfo.myCoin,
                        widget.swap.result.myInfo.myAmount),
                    Expanded(
                      child: Container(),
                    ),
                    _buildIcon(widget.swap.result.myInfo.myCoin),
                    Icon(
                      Icons.sync,
                      size: 20,
                      color: Colors.white,
                    ),
                    _buildIcon(widget.swap.result.myInfo.otherCoin),
                    Expanded(
                      child: Container(),
                    ),
                    _buildTextAmount(widget.swap.result.myInfo.otherCoin,
                        widget.swap.result.myInfo.otherAmount)
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(
                      "UUID: " +
                          widget.swap.result.uuid.substring(0, 5) +
                          "..." +
                          widget.swap.result.uuid.substring(
                              widget.swap.result.uuid.length - 5,
                              widget.swap.result.uuid.length),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.swap.result.myInfo.startedAt * 1000)),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 16),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            color: colorStatus,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(stepStatus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: Colors.white)),
                              SizedBox(
                                width: 4,
                              ),
                              Text(swapStatus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                        color: Colors.white,
                                      ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  _buildIcon(String coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        "assets/${coin.toLowerCase()}.png",
        fit: BoxFit.cover,
      ),
    );
  }

  _buildTextAmount(String coin, String amount) {
    return Text(
      '${(double.parse(amount) % 1) == 0 ? double.parse(amount) : double.parse(amount).toStringAsFixed(4)} $coin',
      style: Theme.of(context).textTheme.body1,
    );
  }

  String getAmountToBuy(Swap swap) {
    return swap.result.myInfo.otherAmount;
  }
}
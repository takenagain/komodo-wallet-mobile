import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/detailed_swap_step.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/progress_step.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

enum SwapStepStatus {
  pending,
  inProgress,
  success,
  failed,
}

class DetailedSwapSteps extends StatefulWidget {
  const DetailedSwapSteps({this.uuid});

  final String uuid;

  @override
  _DetailedSwapStepsState createState() => _DetailedSwapStepsState();
}

class _DetailedSwapStepsState extends State<DetailedSwapSteps> {
  Swap swap;
  Timer timer;
  bool isInProgress = true;
  Duration estimatedTotalSpeed;
  Duration actualTotalSpeed;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
      if (!isInProgress) timer.cancel();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    swap = _swapProvider.swap(widget.uuid) ?? Swap();

    if (swap.status == Status.SWAP_SUCCESSFUL ||
        swap.status == Status.SWAP_FAILED) {
      setState(() {
        isInProgress = false;
      });
    }

    SwapStepStatus _getStatus(int index) {
      if (index == swap.step) return SwapStepStatus.inProgress;
      if (index < swap.step) return SwapStepStatus.success;
      return SwapStepStatus.pending;
      // TODO(yurii): handle SwapStepStatus.failed
    }

    Duration _getEstimatedSpeed(int index) {
      if (index == 0) return const Duration(seconds: 0);

      final StepSpeed stepSpeed = _swapProvider.stepSpeed(
        widget.uuid,
        swap.result.successEvents[index - 1],
        swap.result.successEvents[index],
      );
      return stepSpeed != null ? Duration(milliseconds: stepSpeed.speed) : null;
    }

    Duration _getEstimatedDeviation(int index) {
      if (index == 0) return null;

      final StepSpeed stepSpeed = _swapProvider.stepSpeed(
        widget.uuid,
        swap.result.successEvents[index - 1],
        swap.result.successEvents[index],
      );
      return stepSpeed != null
          ? Duration(milliseconds: stepSpeed.deviation)
          : null;
    }

    Duration _getActualSpeed(int index) {
      if (index == 0) return null; // TODO(yurii): calculate first step speed
      if (index > swap.step) return null;

      final int fromTimestamp = swap.result.events[index - 1].timestamp;
      switch (_getStatus(index)) {
        case SwapStepStatus.inProgress:
          return Duration(
              milliseconds:
                  DateTime.now().millisecondsSinceEpoch - fromTimestamp);
          break;
        case SwapStepStatus.success:
          final int toTimeStamp = swap.result.events[index].timestamp;
          return Duration(milliseconds: toTimeStamp - fromTimestamp);
          break;
        default:
          return null;
      }
    }

    Widget _buildFirstStep() {
      return DetailedSwapStep(
        title: 'Started', // TODO(yurii): localization
        status: _getStatus(0),
        estimatedSpeed: _getEstimatedSpeed(0),
        estimatedDeviation: _getEstimatedDeviation(0),
        actualSpeed: _getActualSpeed(0),
        index: 0,
        actualTotalSpeed: actualTotalSpeed,
        estimatedTotalSpeed: estimatedTotalSpeed,
      );
    }

    List<Widget> _buildFollowingSteps() {
      if (swap.step == 0) return [Container()];

      final List<Widget> list = [];

      for (int i = 1; i < swap.result.successEvents.length; i++) {
        list.add(DetailedSwapStep(
          title: swap.result.successEvents[i],
          status: _getStatus(i),
          estimatedSpeed: _getEstimatedSpeed(i),
          estimatedDeviation: _getEstimatedDeviation(i),
          actualSpeed: _getActualSpeed(i),
          index: i,
          actualTotalSpeed: actualTotalSpeed,
          estimatedTotalSpeed: estimatedTotalSpeed,
        ));
      }

      return list;
    }

    Widget _getSwapStatusIcon() {
      Widget icon = Container();
      switch (swap.status) {
        case Status.SWAP_SUCCESSFUL:
          icon = Icon(Icons.check_circle,
              size: 15, color: Theme.of(context).accentColor);
          break;
        case Status.ORDER_MATCHED:
        case Status.SWAP_ONGOING:
        case Status.ORDER_MATCHING:
          icon = Icon(Icons.swap_horiz,
              size: 15, color: Theme.of(context).accentColor);
          break;
        default:
          icon = Icon(
            Icons.radio_button_unchecked,
            size: 15,
          );
      }

      return Container(
        child: icon,
      );
    }

    void _updateTotals() {
      if (swap.step == 0) return;

      Duration estimatedSumSpeed = const Duration(seconds: 0);
      Duration actualSumSpeed = const Duration(seconds: 0);

      for (var i = 0; i < swap.result.successEvents.length; i++) {
        final SwapStepStatus status = _getStatus(i);

        final Duration actualStepSpeed =
            _getActualSpeed(i) ?? const Duration(seconds: 0);
        actualSumSpeed = durationSum([actualSumSpeed, actualStepSpeed]);

        Duration estimatedStepSpeed = _getEstimatedSpeed(i);
        if (estimatedStepSpeed == null) {
          // If one of the steps does not have estimated speed data
          // we can not calculate total estimated swap speed
          estimatedSumSpeed = null;
          break;
        }

        if (status == SwapStepStatus.success) {
          estimatedStepSpeed = actualStepSpeed;
        } else if (status == SwapStepStatus.inProgress) {
          estimatedStepSpeed = Duration(
              milliseconds: max(actualStepSpeed.inMilliseconds,
                  estimatedStepSpeed.inMilliseconds));
        }

        estimatedSumSpeed =
            durationSum([estimatedSumSpeed, estimatedStepSpeed]);
      }

      setState(() {
        estimatedTotalSpeed = estimatedSumSpeed;
        actualTotalSpeed = actualSumSpeed;
      });
    }

    Widget _buildTotal() {
      _updateTotals();

      return Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            _getSwapStatusIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Total:'), // TODO(yurii): localization
                  estimatedTotalSpeed == null
                      ? Container()
                      : ProgressStep(
                          actualTotalSpeed: actualTotalSpeed,
                          estimatedTotalSpeed: estimatedTotalSpeed,
                          actualStepSpeed: actualTotalSpeed,
                          estimatedStepSpeed: estimatedTotalSpeed,
                        ),
                  Row(
                    children: <Widget>[
                      Text('act: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).accentColor,
                          )),
                      Text(
                        durationFormat(actualTotalSpeed),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      estimatedTotalSpeed == null
                          ? Container()
                          : Row(
                              children: <Widget>[
                                const Text('|',
                                    style: TextStyle(
                                      fontSize: 13,
                                    )),
                                const SizedBox(width: 4),
                                Text('est: ', // TODO(yurii): localization
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).accentColor,
                                    )),
                                Text(
                                  durationFormat(estimatedTotalSpeed),
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Progress details:', // TODO(yurii): localization
            style: Theme.of(context).textTheme.body2,
          ),
          const SizedBox(height: 20),
          _buildTotal(),
          const SizedBox(height: 13),
          // We assume that all kind of swaps has first step, with type of 'Started',
          // so we can show this step before actual swap data received.
          _buildFirstStep(),
          ..._buildFollowingSteps(),
          const SizedBox(height: 12),
          Container(
            child: Text(
              _swapProvider.swapDescription(swap.result?.uuid),
              style: TextStyle(
                fontFamily: 'Monospace',
                color: Theme.of(context).accentColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

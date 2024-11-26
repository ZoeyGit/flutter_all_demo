import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'common.dart';

class LiveHomePage extends StatefulWidget {
  const LiveHomePage({super.key});

  @override
  State<LiveHomePage> createState() => _LiveHomePageState();
}

class _LiveHomePageState extends State<LiveHomePage> {
  List live = [{}, {}, {}, {}, {}, {}, {}, {}, {}];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: List.generate(live.length, (index) {
          return StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: index / 2 == 0 ? 2.5 : 2,
            child: Tile(index: index),
          );
        }),
      ),
    ));
  }
}

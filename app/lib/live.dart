import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class LivePage extends StatelessWidget {
  // 添加静态常量
  static const double _avatarRadius = 15.0;
  static const double _gridPadding = 10.0;
  static const double _tabSpacing = 8.0;
  static const double _navHorizontalPadding = 15.0;
  static const double _navTopPadding = 40.0;

  LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部导航栏
          _buildTopNav(),
          // 分类标签栏
          _buildCategoryTabs(),
          // 主播推荐卡片区
          _buildLiveCards(),
        ],
      ),
    );
  }

  // 顶部导航栏
  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          _navHorizontalPadding, _navTopPadding, _navHorizontalPadding, 0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('关注', style: TextStyle(fontSize: 16)),
              SizedBox(width: 20),
              Text('直播',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Text('精选', style: TextStyle(fontSize: 16)),
            ],
          ),
          Icon(Icons.search),
        ],
      ),
    );
  }

  // 分类标签栏
  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _buildTab('推荐', isSelected: true),
          _buildTab('声控'),
          _buildTab('娱乐'),
          _buildTab('游戏'),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _tabSpacing),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.purple : Colors.black,
        ),
      ),
    );
  }

  // 直播卡片网格
  Widget _buildLiveCards() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // 实现刷新逻辑
          await Future.delayed(const Duration(seconds: 1));
        },
        child: MasonryGridView.builder(
          padding: const EdgeInsets.all(_gridPadding),
          itemCount: _liveCards.length,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemBuilder: (context, index) => _buildLiveCard(_liveCards[index]),
        ),
      ),
    );
  }

  // 修改模拟数据，使其更有变化
  final List<LiveCardData> _liveCards = List.generate(
    20,
    (index) => LiveCardData(
      coverUrl:
          'https://picsum.photos/300/${200 + (index % 4) * 100}', // 更大的高度差异
      title: '${'直播标题 ' * (Random().nextInt(3) + 1)}$index', // 随机标题长度
      anchor: '主播 $index',
      viewers: '${Random().nextInt(1000)}',
      aspectRatio: [3 / 4, 1 / 1, 4 / 3, 16 / 9][Random().nextInt(4)], // 随机宽高比
    ),
  );

  Widget _buildLiveCard(LiveCardData card) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 修改封面图，使用动态宽高比
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: AspectRatio(
              aspectRatio: card.aspectRatio,
              child: Image.network(
                card.coverUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          ),
          // 直播信息
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: null, // 允许标题换行
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: _avatarRadius,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/100/100?random=${card.anchor}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.anchor,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${card.viewers}观看',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
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
}

// 修改数据模型，添加宽高比属性
class LiveCardData {
  final String coverUrl;
  final String title;
  final String anchor;
  final String viewers;
  final double aspectRatio; // 新增宽高比属性

  const LiveCardData({
    required this.coverUrl,
    required this.title,
    required this.anchor,
    required this.viewers,
    required this.aspectRatio,
  });
}

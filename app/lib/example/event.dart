import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum EventType { generated, logout, login }

typedef EventListener = void Function(dynamic data);

///监听事件
class EventService extends GetxService {
  static EventService get to => Get.find();

  final Map<EventType, List<EventListener>> _eventMap = {};

  void add(EventType type, EventListener listener) {
    if (_eventMap.containsKey(type)) {
      _eventMap[type]?.add(listener);
    } else {
      _eventMap[type] = [listener];
    }
  }

  void remove(EventType type, EventListener listener) {
    _eventMap[type]?.remove(listener);
  }

  void post(EventType type, dynamic data) {
    debugPrint('$type 有 ${_eventMap[type]?.length ?? 0} 个监听');
    if (!_eventMap.containsKey(type)) return;
    for (var element in _eventMap[type]!) {
      element.call(data);
    }
  }
}

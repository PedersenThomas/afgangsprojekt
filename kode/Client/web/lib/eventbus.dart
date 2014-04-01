library eventbus;

import 'package:event_bus/event_bus.dart';

final EventType<Map> windowChanged = new EventType<Map>();
final EventType<Map> invalidate = new EventType<Map>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;

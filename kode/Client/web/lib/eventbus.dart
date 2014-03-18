library eventbus;

import 'package:event_bus/event_bus.dart';

final EventType<String> windowChanged = new EventType<String>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;

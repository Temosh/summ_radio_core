package com.summ.radio.events {

import flash.events.Event;

public class StationEvent extends Event {
    public static const TICK:String = "tick";

    public function StationEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
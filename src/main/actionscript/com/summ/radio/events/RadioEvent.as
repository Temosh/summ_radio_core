package com.summ.radio.events {

import flash.events.Event;

public class RadioEvent extends Event {
    public static const CREATED:String = "created";

    public function RadioEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
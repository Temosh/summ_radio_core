package com.summ.radio.utils {

import com.summ.radio.Globals;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.getTimer;

public class Time extends Sprite {
    private static const DELAY:int = 1000;

    private var hour:int = 0;
    private var min:int = 0;
    private var sec:int = 0;
    private var start_time:Number;
    private var time:uint = 0;

    private var timer:Timer;

    private static var timeLabel:TextField = new TextField();

    /**
     * External timer delay for the class Time should be equal to 1000.
     * Otherwise will be used the internal timer.
     */
    public function Time(extTimer:Timer = null) {
        drawTime();

        if (extTimer) {
            if (extTimer.delay == DELAY) {
                trace("Time: Using external timer.");
                timer = extTimer;
            } else {
                trace("Time: External timer delay for the class Time should be equal to 1000. Internal timer will be used!");
                timer = new Timer(DELAY);
            }
        } else {
            timer = new Timer(DELAY);
        }
    }

    private function onTimer(event:Event):void {
        var cur_time:Number = getTimer() / 1000;

        var dt:int = cur_time - start_time - time;

        if (dt) {
            time += dt;
            sec += dt;
        }

        if (sec >= 60) {
            sec = 0;
            min++;

            if (min >= 60) {
                min = 0;
                hour++
            }
        }

        var timeStr:String = "";

        if (hour)
            timeStr = hour.toString() + ":";
        if (hour && min < 10)
            timeStr += "0";
        timeStr += min.toString() + ":";
        if (sec < 10)
            timeStr += "0";
        timeStr += sec.toString();

        timeLabel.text = timeStr;
    }

    private function drawTime():void {
        this.visible = false;

        timeLabel.height = 18;
        timeLabel.selectable = false;
        timeLabel.embedFonts = true; //Use ony embedded fonts
        timeLabel.defaultTextFormat = Globals.TIME_FORMAT;

        this.addChild(timeLabel);
    }

    public function start():void {
        timeLabel.text = "0:00";

        this.visible = true;

        hour = 0;
        min = 0;
        sec = 0;

        time = 0;

        timer.addEventListener(TimerEvent.TIMER, onTimer);

        start_time = getTimer() / 1000;
        timer.start();
    }

    public function stop():void {
        timer.stop();
        timer.reset();
        timer.removeEventListener(TimerEvent.TIMER, onTimer);

        this.visible = false;
    }
}
}
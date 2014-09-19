package com.summ.radio.utils {

import com.summ.radio.Globals;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

public class ByteCounter extends Sprite {
    private static const DELAY:int = 1000;

    private var timer:Timer;

    private var station:Station;

    private var new_bytes:Number;
    private var bytes:Number = 0;
    private var old_bytes:Number = 0;
    //private var byteStr:String;

    private static var byteLabel:TextField = new TextField();

    public function ByteCounter(target:Station, extTimer:Timer = null) {
        station = target;

        drawByte();

        if (extTimer) {
            if (extTimer.delay == DELAY) {
                trace("ByteCounter: Using external timer.");
                timer = extTimer;
            } else {
                trace("ByteCounter: External timer delay for the class ByteCounter should be equal to 1000. Internal timer will be used!");
                timer = new Timer(DELAY);
            }
        } else {
            timer = new Timer(DELAY);
        }
    }

    private function onTimer(event:Event):void {
        new_bytes = station.bytesLoaded;
        if (new_bytes + old_bytes < bytes)
            old_bytes = bytes;
        bytes = new_bytes + old_bytes;
        //byteStr = station.bytesLoaded / 1024 + " KB";
        byteLabel.text = uint(bytes / 1024) + " KB";
    }

    public function start():void {
        this.visible = true;

        byteLabel.text = "0 KB";
        bytes = 0;
        old_bytes = 0;

        timer.addEventListener(TimerEvent.TIMER, onTimer);

        timer.start();
    }

    public function stop():void {
        timer.stop();
        timer.reset();
        timer.removeEventListener(TimerEvent.TIMER, onTimer);

        this.visible = false;
    }

    private function drawByte():void {
        this.visible = false;

        byteLabel.height = 20;
        byteLabel.width = 100;
        byteLabel.selectable = false;
        byteLabel.embedFonts = true; //Use ony embedded fonts
        byteLabel.defaultTextFormat = Globals.BYTE_FORMAT;

        this.addChild(byteLabel);
    }
}
}
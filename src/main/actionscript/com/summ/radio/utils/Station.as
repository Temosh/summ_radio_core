package com.summ.radio.utils {

import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.Timer;

public class Station extends EventDispatcher {
    private static const DELAY:int = 5000;

    private var wait:Boolean = false; //!!!TEMP!!!

    private var reconection:Boolean;

    private var playing:Boolean;
    private var old_bytes:Number = 0;

    private var vol:Number = 1;
    private var muted:Boolean = false;

    private var stream:String;
    private var station:Sound;
    private var channel:SoundChannel = new SoundChannel();
    private var trans:SoundTransform = new SoundTransform();

    private var timer:Timer;

    public function Station(reconection:Boolean = true) {
        this.reconection = reconection;
    }

    public function play(stream:String):void {
        this.stream = stream;

        var urlRequest:URLRequest = new URLRequest(stream);

        station = new Sound();
        station.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent):void {
            trace(evt)
        }); //TODO!!!

        station.load(urlRequest, new SoundLoaderContext(1000, true));
        //station.addEventListener(Event.COMPLETE, stationComplete);

        timer = new Timer(DELAY);
        timer.addEventListener(TimerEvent.TIMER, onTimer);

        if (muted) {
            trans.volume = 0;
        } else {
            trans.volume = vol;
        }
        channel = station.play();
        channel.soundTransform = trans;

        timer.start();

        playing = true;
    }

    private function stationComplete(event:Event):void {

    }

    private function onTimer(event:Event):void {
        var bytes:Number = station.bytesLoaded;

        if (bytes > old_bytes) {
            old_bytes = bytes;
            wait = false; //!!!TEMP!!!
        } else {
            if (!wait) { //!!!TEMP!!!
                wait = true;
            } else {
                old_bytes = 0;
                wait = false;
                reconect();
            }
        }
    }

    private function reconect():void {
        trace("conecting...");
        stop();
        play(stream);
    }

    public function stop():void {
        playing = false;

        channel.stop();
        try {
            station.close();
            station = null; // *** ! ! ! ***
        }
        catch (error:IOError) {
        }

        timer.stop();
        timer.removeEventListener(TimerEvent.TIMER, onTimer);

        //bytes = 0;
    }

    public function setVolume(volume:int):void {
        vol = volume / 100;

        //trace("Station: Volume =", vol);

        trans.volume = vol;
        channel.soundTransform = trans;
        muted = false;
    }

    public function getVolume():int {
        return vol * 100;
    }

    public function mute():void {
        trans.volume = 0;
        channel.soundTransform = trans;
        muted = true;
    }

    public function unmute():void {
        trans.volume = vol;
        channel.soundTransform = trans;
        muted = false;
    }

    public function isPlaying():Boolean {
        return playing;
    }

    public function get bytesLoaded():uint {
        if (playing) {
            return station.bytesLoaded;
        } else {
            return 0;
        }
    }
}
}
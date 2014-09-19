package com.summ.radio.utils {

import flash.events.*;
import flash.events.TimerEvent;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.utils.Timer;

public class Display extends Visual {
    // Constants:
    private static const SPECTRUM_LENGTH:Number = 512;
    private static const N_COLS:int = 16;
    private static const DELAY:int = 0;

    // Private Properties:
    private var timer:Timer;
    private var errCount:int;

    private var reduction:int;
    private var bytes:ByteArray;
    private var resultTemplate:Array;

    // Initialization:
    public function Display() {
        stopBuf();

        reduction = Math.round(SPECTRUM_LENGTH / N_COLS);
        bytes = new ByteArray();
        resultTemplate = [];
        for (var i:int = 0; i < N_COLS; i++) resultTemplate.push(0);
    }

    // Public Methods:

    public function startEq():void {
        errCount = 0;

        timer = new Timer(DELAY);
        timer.addEventListener(TimerEvent.TIMER, onTimer);
        timer.start();
        //this.addEventListener(Event.ENTER_FRAME, onTimer);
    }

    public function stopEq():void {
        timer.stop();
        timer.removeEventListener(TimerEvent.TIMER, onTimer);
        //this.removeEventListener(Event.ENTER_FRAME, onTimer);

        for (var i:int = 0; i < N_COLS; i++) {
            this.equalizer["eq_" + i].gotoAndStop(0);
        }
        stopBuf();
    }

    public function startBuf():void {
        this.bufAnim.buf_mc.play();
    }

    public function stopBuf():void {
        this.bufAnim.buf_mc.gotoAndStop(0);
    }

    // Private Methods:

    //private function onTimer(event:TimerEvent):void {
    private function onTimer(event:Event):void {
        var levelArr:Array = getSpectrum();

        for (var i:int = 0; i < N_COLS; i++) {
            this.equalizer["eq_" + i].gotoAndStop(Math.ceil(levelArr[i] * 10));
        }
    }

    public function getSpectrum():Array {
        var spectrumResult:Array = [];

        try {
            SoundMixer.computeSpectrum(bytes, true, 0);
            spectrumResult = byMaximumValues(bytes);

        } catch (e:Error) {
            errCount++;
            if (errCount > 50) {
                stopEq();
                startBuf();
            }
            // the computeSpectrum() throws a "Security violation" error occurs sometimes. Ignore it.
        }

        // Optionally the results can by multiplied (no need if byMaximumValues() is used)
        // result = multiply(result, 1.4);

        return reverseLeftChannel(spectrumResult);
    }

    /**
     * This and the following methods reduce the data from the spectrum bytearray to an array of Numbers of the correct size
     * (= value of the 'size' property).
     *
     * This method returns the maximum value from each group.
     */
    private function byMaximumValues(spectrum:ByteArray):Array {
        var byMax:Array = resultTemplate.concat();

        for (var i:uint = 0; i < SPECTRUM_LENGTH; i++)
            byMax[Math.floor(i / reduction)] = Math.max(spectrum.readFloat(), byMax[Math.floor(i / reduction)]);

        return byMax;
    }

    /**
     * Multiplies each value by factor but forces it to be < 1.
     */
    private function multiply(result:Array, factor:Number):Array {
        var multiplied:Array = [];

        for (var i:int = 0; i < N_COLS; i++)
            multiplied.push(Math.min((result[i] * factor), 1));

        return multiplied;
    }

    /**
     * Reverses the left half of the result values so that Equalizer
     * has the form of a pyramid '/\' rather than of two triangles '|\|\'
     */
    private function reverseLeftChannel(result:Array):Array {
        var reversed:Array = [];

        for (var i:int = 0; i < N_COLS; i++) {
            var si:uint = (i < (N_COLS / 2)) ? (N_COLS / 2) - i - 1 : i;
            reversed[si] = result[i];
        }

        return reversed;
    }

}
}
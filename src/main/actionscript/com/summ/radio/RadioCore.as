package com.summ.radio {

import com.summ.radio.events.RadioEvent;
import com.summ.radio.utils.ByteCounter;
import com.summ.radio.utils.Display;
import com.summ.radio.utils.Station;
import com.summ.radio.utils.Time;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFormat;

public class RadioCore extends Sprite {
    //public var main:Sprite = new Sprite();

    private var configs:Object;

    //---------------------------
    //		***Components***
    //---------------------------
    private var play_but:PlayBut;
    private var stop_but:StopBut;
    private var mute_but:MuteBut;
    private var unmute_but:UnMuteBut;
    private var next_but:NextBut;
    private var prev_but:NextBut;
    private var volSlider:VolSlider;
    private var display:Display;
    private var logo:Logo;
    private var time:Time;
    private var byteCount:ByteCounter;

    //public static const SKIN_URL:URLRequest = new URLRequest("xml/skins.xml");
    private var _skinURL:URLRequest;

    //public static const XML_URL:URLRequest = new URLRequest("xml/music.xml");
    private var _xmlURL:URLRequest;

    public static const START_VOL:int = 100;

    private var slBounds:Rectangle = new Rectangle(0, 0, 100, 0);

    private var selStation:int;
    private var curStation:int;
    private var playlist:Array = [];
    private var nList:int;

    private var station:Station = new Station();

    /**
     *            EMBED FONTS
     *
     * U+0020-U+0040, /Punctuation, Numbers and Symbols/
     * U+0041-U+005A, /Upper-Case A-Z/
     * U+005B-U+0060, /Punctuation and Symbols/
     * U+0061-U+007A, /Lower-Case a-z/
     * U+007B-U+007E; /Punctuation and Symbols/
     */
    [Embed(source="../../../../resources/fonts/ITCKRIST.TTF", embedAsCFF='false', fontName='KRISTEN_ITC', unicodeRange='U+0020-007E')]
    private var FONT_KRISTEN_ITC:String;

    private static var infoLabel:TextField = new TextField();

    public function RadioCore() {

    }

    /**
     * Initialize components
     */
    public function initComponents():void {

        //---------Define skinnable components---------
        //Play
        play_but = new PlayBut();
        //Stop
        stop_but = new StopBut();
        //Mute
        mute_but = new MuteBut();
        //Unmute
        unmute_but = new UnMuteBut();
        unmute_but.visible = false;
        //Next
        next_but = new NextBut();
        next_but.visible = false;
        //Prev
        prev_but = new NextBut();
        prev_but.rotation = 180; //TODO
        prev_but.visible = false;
        //Volume Slider
        volSlider = new VolSlider();
        volSlider.vol_handle.buttonMode = true;
        volSlider.vol_handle.x = START_VOL;
        //Display
        display = new Display();
        //Logo
        logo = new Logo();
        logo.buttonMode = true;
        logo.visible = true;

        //---------Define simple components
        //Station
        station.setVolume(START_VOL);
        //StationLabel
        infoLabel.width = 320;
        infoLabel.height = 40;
        infoLabel.x = 40;
        infoLabel.y = 110;
        infoLabel.selectable = false;
        infoLabel.embedFonts = true; //Use ony embedded fonts
        infoLabel.defaultTextFormat = Globals.TEXT_FORMAT;
        //Time
        time = new Time(Globals.instance.secTimer);
        //ByteCount
        byteCount = new ByteCounter(station, Globals.instance.secTimer);

        //---------Loaders---------
        var skinLoad:URLLoader = new URLLoader(_skinURL);
        skinLoad.addEventListener(Event.COMPLETE, skinComplete);

        var stationLoad:URLLoader = new URLLoader(_xmlURL);
        stationLoad.addEventListener(Event.COMPLETE, playlistComplete);

        //---------Create event listeners---------
        play_but.addEventListener(MouseEvent.MOUSE_DOWN, playDown);
        stop_but.addEventListener(MouseEvent.MOUSE_DOWN, stopDown);
        mute_but.addEventListener(MouseEvent.MOUSE_DOWN, muteDown);
        unmute_but.addEventListener(MouseEvent.MOUSE_DOWN, unmuteDown);
        next_but.addEventListener(MouseEvent.MOUSE_DOWN, nextStation);
        prev_but.addEventListener(MouseEvent.MOUSE_DOWN, prevStation);
        logo.addEventListener(MouseEvent.MOUSE_DOWN, logoClick);
        volSlider.vol_handle.addEventListener(MouseEvent.MOUSE_DOWN, volHandle);

        //---------Add to stage---------
        addChild(new Background());
        addChild(play_but);
        addChild(stop_but);
        addChild(mute_but);
        addChild(unmute_but);
        addChild(next_but);
        addChild(prev_but);
        addChild(volSlider);
        addChild(display);
        addChild(time);
        addChild(byteCount);
        addChild(infoLabel);
        addChild(logo);
    }

    private function skinComplete(event:Event):void {
        var skinXML:XML = new XML(event.currentTarget.data);

        play_but.x = skinXML.play.@x;
        play_but.y = skinXML.play.@y;
        play_but.width = skinXML.play.@width;
        play_but.height = skinXML.play.@height;

        stop_but.x = skinXML.stop.@x;
        stop_but.y = skinXML.stop.@y;

        mute_but.x = skinXML.mute.@x;
        mute_but.y = skinXML.mute.@y;

        unmute_but.x = skinXML.unmute.@x;
        unmute_but.y = skinXML.unmute.@y;

        next_but.x = skinXML.next.@x;
        next_but.y = skinXML.next.@y;

        prev_but.x = skinXML.prev.@x;
        prev_but.y = skinXML.prev.@y;

        volSlider.x = skinXML.vol.@x;
        volSlider.y = skinXML.vol.@y;
        volSlider.width = skinXML.vol.@width;
        volSlider.height = skinXML.vol.@height;

        display.x = skinXML.visual.@x;
        display.y = skinXML.visual.@y;

        logo.x = skinXML.logo.@x;
        logo.y = skinXML.logo.@y;
        logo.width = skinXML.logo.@width;
        logo.height = skinXML.logo.@height;

        time.x = skinXML.time.@x;
        time.y = skinXML.time.@y;

        byteCount.x = skinXML.byte.@x;
        byteCount.y = skinXML.byte.@y;

        dispatchEvent(new Event(RadioEvent.CREATED));
    }

    private function playlistComplete(event:Event):void {
        var i:int = 0;
        var item:Object;
        var stationXML:XML = new XML(event.currentTarget.data);

        for each (var prop:XML in stationXML.station) {
            i++;
            item = {};
            item.id = i;
            item.name = String(prop.@disp);
            item.source = String(prop.@id);
            playlist.push(item);
        }

        updatePlaylist();
    }

    public function updatePlaylist():void {
        nList = playlist.length;

        // Print first station
        if (nList > 0) {
            selStation = 0;
            print(playlist[selStation].name);

            prev_but.visible = false;
            if (nList > 1) {
                next_but.visible = true;
            } else {
                next_but.visible = false;
            }
        } else {
            next_but.visible = false;
            prev_but.visible = false;
            print("Nothing to play", Globals.ERR_TEXT_FORMAT);
        }
    }

    private function playDown(event:MouseEvent):void {
        if (!station.isPlaying() || selStation != curStation) {
            if (station.isPlaying()) {
                station.stop();
                display.stopEq();
            }

            station.play(playlist[selStation].source);
            time.start();
            byteCount.start();
            logo.visible = false;
            display.startEq();

            curStation = selStation;
        }
    }

    private function stopDown(event:MouseEvent):void {
        if (station.isPlaying()) {
            station.stop();
            time.stop();
            byteCount.stop();
            display.stopEq();
        }
        logo.visible = true;
    }

    private function muteDown(event:MouseEvent):void {
        station.mute();

        mute_but.visible = false;
        unmute_but.visible = true;
    }

    private function unmuteDown(event:MouseEvent):void {
        station.unmute();

        unmute_but.visible = false;
        mute_but.visible = true;
    }

    private function nextStation(event:MouseEvent):void {
        selStation++;
        prev_but.visible = true;

        infoLabel.text = playlist[selStation].name;
        infoLabel.setTextFormat(Globals.TEXT_FORMAT);

        if (selStation == nList - 1) {
            next_but.visible = false;
        }
    }

    private function prevStation(event:MouseEvent):void {
        selStation--;
        next_but.visible = true;

        infoLabel.text = playlist[selStation].name;
        infoLabel.setTextFormat(Globals.TEXT_FORMAT);

        if (selStation == 0) {
            prev_but.visible = false;
        }
    }

    private function volHandle(event:MouseEvent):void {
        this.volSlider.vol_handle.startDrag(true, slBounds);

        this.volSlider.stage.addEventListener(MouseEvent.MOUSE_MOVE, changeVol);
        this.volSlider.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
    }

    private function endDrag(event:MouseEvent):void {
        this.volSlider.vol_handle.stopDrag();

        var vol:int = this.volSlider.vol_handle.x;
        station.setVolume(vol);

        unmute_but.visible = false;
        mute_but.visible = true;

        this.volSlider.stage.removeEventListener(MouseEvent.MOUSE_MOVE, changeVol);
        this.volSlider.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
    }

    private function changeVol(event:MouseEvent):void {
        var vol:int = this.volSlider.vol_handle.x;
        station.setVolume(vol);
    }

    private function logoClick(event:MouseEvent):void {
        navigateToURL(new URLRequest("http://summoner.at.ua"));
    }

    public function print(str:String, form:TextFormat = null):void {
        if (!form)
            form = Globals.TEXT_FORMAT;

        infoLabel.text = str;
        infoLabel.setTextFormat(form);
    }

    public function set skinURL(url:URLRequest):void {
        _skinURL = url;
    }

    public function set xmlURL(url:URLRequest):void {
        _xmlURL = url;
    }

    public function getPlaylist():Array {
        return playlist
    }

    public function setPlaylist(playlist:Array):void {
        this.playlist = playlist;
        updatePlaylist();
    }
}
}
package com.summ.radio.utils {

public class PlaylistItem {
    private var _source:String;
    private var _name:String;

    public function PlaylistItem(name:String, source:String) {
        _name = name;
        _source = source;
    }

    public function get name():String {
        return _name;
    }

    public function get source():String {
        return _source;
    }

    public function set name(name:String):void {
        _name = name;
    }

    public function set source(source:String):void {
        _source = source;
    }
}
}
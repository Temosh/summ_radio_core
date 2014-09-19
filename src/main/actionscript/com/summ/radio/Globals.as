package com.summ.radio {

import flash.text.TextFormat;
import flash.utils.Timer;

public class Globals {
    public static const TEXT_FORMAT     :TextFormat = new TextFormat("KRISTEN_ITC", 26, 0x006600, null, null, null, null, null, "center");
    public static const ERR_TEXT_FORMAT :TextFormat = new TextFormat("KRISTEN_ITC", 26, 0xFF0000, null, null, null, null, null, "center");
    public static const TIME_FORMAT     :TextFormat = new TextFormat("KRISTEN_ITC", 16, 0x006600);
    public static const BYTE_FORMAT     :TextFormat = new TextFormat("KRISTEN_ITC", 16, 0x006600, null, null, null, null, null, "right");

    public var secTimer                 :Timer      = new Timer(1000);

    private static var _instance        :Globals;

    /**
     *  Get the singleton instance of the Globals.
     */
    public static function get instance():Globals {
        if (!_instance) {
            _instance = new Globals();
        }

        return _instance;
    }
}
}
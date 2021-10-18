package com.dexterous.flutterlocalnotifications.utils;

import android.app.ActivityManager;

public class Util {

    public static  boolean foregrounded() {
        ActivityManager.RunningAppProcessInfo myProcess = new ActivityManager.RunningAppProcessInfo();
        ActivityManager.getMyMemoryState(myProcess);
        return  myProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND;
    }

    public static  String getAppState() {
        if(foregrounded())
            return  "foreground";
        else
            return  "background";
    }


}


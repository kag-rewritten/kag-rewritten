﻿using Jint;
using Jint.Native;

namespace KAG.Runtime.Utils
{
    public class GameUtils : BaseUtils
    {
        public GameUtils(GameModule gameModule) : base(gameModule)
        {
            module.SetGlobalObject("Utils", this);
        }

        public JsValue ParseJson(string filePath)
        {
            var file = module.Get<GameModuleJsonFile>(filePath);
            if (file != null)
            {
                return file.GetObject();
            }
            return JsValue.Null;
        }
    }

    public class BaseUtils
    {
        protected GameModule module;

        public BaseUtils(GameModule gameModule)
        {
            module = gameModule;
        }
    }
}
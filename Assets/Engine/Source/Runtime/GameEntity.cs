﻿using Mirror;
using Jint;
using Jint.Native;

namespace KAG.Runtime
{
    public class GameEntity : NetworkBehaviour
    {
        protected GameEngine engine => GameManager.Instance.engine;

        public JsValue controller;

        protected virtual void Start()
        {
            SetValue("isMine", isLocalPlayer);
            SetValue("isClient", isClient);
            SetValue("isServer", isServer);

            Call("Start");
        }

        protected virtual void Update()
        {
            Call("Update");
        }

        public JsValue GetValue(string property)
        {
            return controller.AsObject().Get(property);
        }

        public void SetValue(string property, JsValue value)
        {
            controller.AsObject().Set(property, value);
        }

        public void Call(string function, params object[] arguments)
        {
            if (controller != null)
            {
                if (engine.GetValue(controller, function).IsUndefined())
                {
                    return;
                }

                engine.Invoke(controller.Get(function), controller, arguments);
            }
        }
    }
}
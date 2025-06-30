using UnityEngine;
using UnityEngine.InputSystem;
using System;
using TMPro;
namespace cowsins
{
    /// <summary>
    /// Manages player inputs and broadcasts them to other scripts.
    /// </summary>
    public class InputManager : MonoBehaviour
    {
        #region events
        public static Action onInventoryOpenPressed, onInventoryFavOpenPressed;
        public static Action onDrop, onJump, onDash, onInspect, onMelee, onShoot, onStopShoot, onTogglePause, onToggleFlashlight, onStartGrapple, onStopGrapple, onBackUI;

        public static event Action rebindComplete;
        public static event Action rebindCanceled;
        public static event Action<InputAction, int> rebindStarted;
        #endregion

        #region variables
        // Inputs
        public static bool shooting = false,
            shootingDown,
            reloading,
            aiming,
            jumping,
            sprinting,
            crouching,
            interacting,
            startInteraction,
            dropping,
            nextweapon,
            previousweapon,
            inspecting,
            melee,
            pausing,
            dashing,
            invertedAxis,
            yMovementActioned,
            openInventory,
            openFavMenu,
            toggleFlashLight,
            grappling,
            backUI,
            selectUI,
            westButtonUI,
            nortButtonUI;

        public static float x,
            y,
            scrolling,
            mousex,
            mousey,
            controllerx,
            controllery,
            sensitivity_x = 50f,
            sensitivity_y = 50f,
            controllerSensitivityX = 30f,
            controllerSensitivityY = 30f,
            aimingSensitivityMultiplier = .5f;

        private bool ToggleAiming;

        public enum curDevice
        {
            Keyboard, Gamepad
        };

        public static InputManager inputManager;

        public static PlayerActions inputActions;

        private PlayerMovement player;

        private WeaponController weaponController;

        private Vector2 moveInput;

        private bool ToggleCrouching, ToggleSprinting;
        #endregion

        private void Awake()
        {
            // Handle singleton
            if (inputManager == null)
            {
                inputManager = this;
            }
            else
            {
                Destroy(this.gameObject);
                return;
            }

            Init();

            inputActions.GameControls.Crouching.started += ctx => ToggleCrouching = true;
            inputActions.GameControls.Crouching.canceled += ctx => ToggleCrouching = false;

            inputActions.GameControls.Sprinting.started += ctx => ToggleSprinting = true;
            inputActions.GameControls.Sprinting.canceled += ctx => ToggleSprinting = false;

            inputActions.GameControls.Aiming.started += ctx => ToggleAiming = true;
            inputActions.GameControls.Aiming.canceled += ctx => ToggleAiming = false;

            inputActions.GameControls.Pause.started += ctx => onTogglePause?.Invoke();

            inputActions.GameControls.InventoryOpen.performed += ctx => onInventoryOpenPressed?.Invoke();
            inputActions.GameControls.InventoryFavOpen.performed += ctx => onInventoryFavOpenPressed?.Invoke();

            inputActions.GameControls.Drop.started += ctx => onDrop?.Invoke();
            inputActions.GameControls.Jumping.started += ctx => onJump?.Invoke();
            inputActions.GameControls.Dashing.started += ctx => onDash?.Invoke();
            inputActions.GameControls.Inspect.started += ctx => onInspect?.Invoke();
            inputActions.GameControls.Melee.started += ctx => onMelee?.Invoke();
            inputActions.GameControls.ToggleFlashLight.started += ctx => onToggleFlashlight?.Invoke();
            inputActions.GameControls.Grapple.started += ctx => onStartGrapple?.Invoke();
            inputActions.GameControls.Grapple.canceled += ctx => onStopGrapple?.Invoke();
            
            inputActions.UI.Back.started += ctx => onBackUI?.Invoke();

            inputActions.GameControls.Firing.started += ctx => {
                shooting = true;    
                onShoot?.Invoke();
            };
            inputActions.GameControls.Firing.canceled += ctx =>
            {
                shooting = false;
                onStopShoot?.Invoke();
            };
        }

        private void OnDisable()
        {
            inputActions.GameControls.Drop.started -= ctx => onDrop?.Invoke();
            inputActions.GameControls.Jumping.started -= ctx => onJump?.Invoke();
            inputActions.GameControls.Dashing.started -= ctx => onDash?.Invoke();
            inputActions.GameControls.Inspect.started -= ctx => onInspect?.Invoke();
            inputActions.GameControls.Melee.started -= ctx => onMelee?.Invoke();
            inputActions.GameControls.Firing.started -= ctx => onShoot?.Invoke();
            inputActions.GameControls.Firing.canceled -= ctx => onStopShoot?.Invoke();
            inputActions.GameControls.ToggleFlashLight.started -= ctx => onToggleFlashlight?.Invoke();

            onDrop = null;
            onJump = null;
            onDash = null;
            onInspect = null;
            onMelee = null; 
            onShoot = null; 
            onStopShoot = null; 

            inputActions.Disable();
        }
        private void Update()
        {
            if (player == null) return;
            // Handle all the required inputs here
            if (GameSettingsManager.Instance)
            {
                sensitivity_x = GameSettingsManager.Instance.playerSensX;
                sensitivity_y = GameSettingsManager.Instance.playerSensY;
                controllerSensitivityX = GameSettingsManager.Instance.playerControllerSensX;
                controllerSensitivityY = GameSettingsManager.Instance.playerControllerSensY;
            }
            else
            {
                sensitivity_x = player.sensitivityX;
                sensitivity_y = player.sensitivityY;
                controllerSensitivityX = player.controllerSensitivityX;
                controllerSensitivityY = player.controllerSensitivityY;
            }

            aimingSensitivityMultiplier = player.aimingSensitivityMultiplier;

            if (Mouse.current != null)
            {
                mousex = Mouse.current.delta.x.ReadValue();
                mousey = Mouse.current.delta.y.ReadValue();

            }

            if (Gamepad.current != null)
            {
                controllerx = Gamepad.current.rightStick.x.ReadValue();
                controllery = -Gamepad.current.rightStick.y.ReadValue();
            }

            moveInput = inputActions.GameControls.Movement.ReadValue<Vector2>();
            x = moveInput.x;
            y = moveInput.y;

            yMovementActioned = y > 0;

            shootingDown = inputActions.GameControls.Firing.WasPressedThisFrame();
            reloading = inputActions.GameControls.Reloading.IsPressed();
            melee = inputActions.GameControls.Melee.WasPressedThisFrame();

            scrolling = inputActions.GameControls.Scrolling.ReadValue<Vector2>().y;
            nextweapon = inputActions.GameControls.ChangeWeapons.WasPressedThisFrame() && inputActions.GameControls.ChangeWeapons.ReadValue<float>() > 0;
            previousweapon = inputActions.GameControls.ChangeWeapons.WasPressedThisFrame() && inputActions.GameControls.ChangeWeapons.ReadValue<float>() < 0;

            if (weaponController.alternateAiming && weaponController.weapon != null)
            {
                if (ToggleAiming) { aiming = !aiming; ToggleAiming = false; }
            }
            else
            {
                aiming = inputActions.GameControls.Aiming.IsPressed();
            }

            interacting = inputActions.GameControls.Interacting.IsPressed();
            startInteraction = inputActions.GameControls.Interacting.WasPressedThisFrame();
            openInventory = inputActions.GameControls.InventoryOpen.WasPressedThisFrame();
            openFavMenu = inputActions.GameControls.InventoryFavOpen.WasPressedThisFrame();
            dropping = inputActions.GameControls.Drop.WasPressedThisFrame();

            inspecting = inputActions.GameControls.Inspect.IsPressed();

            toggleFlashLight = inputActions.GameControls.ToggleFlashLight.WasPressedThisFrame();

            grappling = inputActions.GameControls.Grapple.IsPressed();

            dashing = inputActions.GameControls.Dashing.WasPressedThisFrame();
            jumping = inputActions.GameControls.Jumping.WasPressedThisFrame();

            // Handle different crouching methods
            if (player.alternateCrouch)
            {
                if (ToggleCrouching)
                {
                    crouching = !crouching;
                    ToggleCrouching = false;
                }
            }
            else
            {
                crouching = inputActions.GameControls.Crouching.IsPressed();
            }

            if (player.alternateSprint)
            {
                if (ToggleSprinting)
                {
                    sprinting = !sprinting;
                    ToggleSprinting = false;
                }
            }
            else
                sprinting = inputActions.GameControls.Sprinting.IsPressed();

            backUI = inputActions.UI.Back.WasPressedThisFrame();
            selectUI = inputActions.UI.Select.WasPressedThisFrame();
            westButtonUI = inputActions.UI.WestButton.WasPressedThisFrame();
            nortButtonUI = inputActions.UI.NorthButton.WasPressedThisFrame();
            pausing = inputActions.GameControls.Pause.WasPressedThisFrame();
        }

        private void FixedUpdate()
        {
            y = inputActions.GameControls.Movement.ReadValue<Vector2>().y;
        }

        #region others

        public static void ToggleGameControls(bool enable)
        {
            if (enable) inputActions.GameControls.Enable();
            else inputActions.GameControls.Disable();
        }

        public static void ToggleUIControls(bool enable)
        {
            if (enable) inputActions.UI.Enable();
            else inputActions.UI.Disable();
        }

        private void Init()
        {
            // Initialize Inputs
            if (inputActions == null) inputActions = new PlayerActions();
            inputActions.Enable();
            // Load saved bindings overrides
            LoadAllBindings();

            ToggleGameControls(true);
            ToggleUIControls(false);
        }

        private void LoadAllBindings()
        {
            // Iterate through all the acction maps in the Player Actions
            foreach (var actionMap in inputActions.asset.actionMaps)
            {
                foreach (var action in actionMap.actions)
                {
                    // For each of the bindings of each of the actions, load the binding binding from PlayerPrefs
                    for (int i = 0; i < action.bindings.Count; i++)
                    {
                        LoadBindingOverride(action, i);
                    }
                }
            }
        }

        private static void LoadBindingOverride(InputAction action, int bindingIndex)
        {

            // Gather the path from the Player Prefs
            string overridePath = PlayerPrefs.GetString(action.actionMap + action.name + bindingIndex);
            // If the path is valid, apply it to the action that needs to be loaded.
            if (!string.IsNullOrEmpty(overridePath))
            {
                action.ApplyBindingOverride(bindingIndex, overridePath);
            }
        }

        /// <summary>
        /// Sets the player that the InputManager will take as a reference
        /// </summary>
        /// <param name="player"></param>
        public void SetPlayer(PlayerMovement player)
        {
            this.player = player;
            weaponController = player.GetComponent<WeaponController>();
        }

        public static void StartRebind(string actionName, int bindingIndex, TextMeshProUGUI statusTxt, bool excludeMouse, GameObject rebindOverlay, TextMeshProUGUI rebindOverlayTitle)
        {
            // Find the Input Action based on its name
            InputAction action = inputActions.asset.FindAction(actionName);

            if (action == null || action.bindings.Count <= bindingIndex)
            {
                Debug.LogError("Action or Binding not Found");
                return;
            }

            // If it is valid check if it is a composite
            // Iterate through each each composite part and rebind it
            if (action.bindings[bindingIndex].isComposite)
            {
                var firstPartIndex = bindingIndex + 1;

                if (firstPartIndex < action.bindings.Count && action.bindings[firstPartIndex].isComposite) PerformRebind(action, bindingIndex, statusTxt, true, excludeMouse, rebindOverlay, rebindOverlayTitle);
            }
            else PerformRebind(action, bindingIndex, statusTxt, false, excludeMouse, rebindOverlay, rebindOverlayTitle);
        }
        private static void PerformRebind(InputAction actionToRebind, int bindingIndex, TextMeshProUGUI statusTxt, bool allCompositeParts, bool excludeMouse, GameObject rebindOverlay, TextMeshProUGUI rebindOverlayTitle)
        {
            if (actionToRebind == null || bindingIndex < 0)
                return;

            // Update the text status
            statusTxt.text = $"Press a {actionToRebind.expectedControlType}";
            rebindOverlay.SetActive(true);
            rebindOverlayTitle.text = $"Rebinding {actionToRebind.name}";
            actionToRebind.Disable();

            var rebind = actionToRebind.PerformInteractiveRebinding(bindingIndex);

            // Handle rebind completion
            rebind.OnComplete(operation =>
            {
                rebindOverlay.SetActive(false);
                // Enable the rebind and stop the operation
                actionToRebind.Enable();
                operation.Dispose();

                // Rebind for Composite
                if (allCompositeParts)
                {
                    var nextBindingIndex = bindingIndex + 1;
                    if (nextBindingIndex < actionToRebind.bindings.Count && actionToRebind.bindings[nextBindingIndex].isComposite) PerformRebind(actionToRebind, nextBindingIndex, statusTxt, allCompositeParts, excludeMouse, rebindOverlay, rebindOverlayTitle);
                }

                // Save the new rebinds
                SaveBindingOverride(actionToRebind);

                rebindComplete?.Invoke();
            });

            // Handle rebind cancel
            rebind.OnCancel(operation =>
            {
                rebindOverlay.SetActive(false);
                actionToRebind.Enable();
                operation.Dispose();

                rebindCanceled?.Invoke();
            });

            // Cancel rebind if pressing escape
            rebind.WithCancelingThrough("<Keyboard>/escape");

            // Exclude mouse
            if (excludeMouse)
                rebind.WithControlsExcluding("<Mouse>/escape");

            rebindStarted?.Invoke(actionToRebind, bindingIndex);
            // Actually start the rebind process
            rebind.Start();
        }


        /// <summary>
        /// Retrieve the name of a binding.
        /// </summary>
        /// <param name="actionName"></param>
        /// <param name="bindingIndex"></param>
        /// <returns></returns>
        public static string GetBindingName(string actionName, int bindingIndex)
        {
            if (inputActions == null) inputActions = new PlayerActions();

            InputAction action = inputActions.asset.FindAction(actionName);
            return action.GetBindingDisplayString(bindingIndex);
        }

        // Save the bindings into player prefs for each action
        private static void SaveBindingOverride(InputAction action)
        {
            for (int i = 0; i < action.bindings.Count; i++)
            {
                PlayerPrefs.SetString(action.actionMap + action.name + i, action.bindings[i].overridePath);
            }
        }

        public static void LoadBindingOverride(string actionName)
        {
            if (inputActions == null)
                inputActions = new PlayerActions();
            // Gather the Input Action given its name
            InputAction action = inputActions.asset.FindAction(actionName);

            // For each binding apply the binding from PlayerPrefs
            for (int i = 0; i < action.bindings.Count; i++)
            {
                if (!string.IsNullOrEmpty(PlayerPrefs.GetString(action.actionMap + action.name + i)))
                    action.ApplyBindingOverride(i, PlayerPrefs.GetString(action.actionMap + action.name + i));
            }
        }

        /// <summary>
        /// Reset the bindings for the given action
        /// </summary>
        /// <param name="actionName"></param>
        /// <param name="bindingIndex"></param>
        public static void ResetBinding(string actionName, int bindingIndex)
        {
            // Gather the Input Action given its name
            InputAction action = inputActions.asset.FindAction(actionName);

            if (action == null || action.bindings.Count <= bindingIndex)
            {
                Debug.LogError("Action or Binding not found");
                return;
            }
            if (action.bindings[bindingIndex].isComposite)
            {
                for (int i = bindingIndex; i < action.bindings.Count && action.bindings[i].isComposite; i++)
                    action.RemoveBindingOverride(i);
            }
            else
                action.RemoveBindingOverride(bindingIndex);

            SaveBindingOverride(action);
        }
        #endregion
    }

}

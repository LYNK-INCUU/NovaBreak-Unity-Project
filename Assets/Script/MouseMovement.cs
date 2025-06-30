using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseMovement : MonoBehaviour
{
        public float mousesensitivity = 500f;

        float xRotation = 0f;
        float yRotation = 0f;

        public float topClamp = -90.0f;
        public float bottomClamp = 90.0f;

    void Start()
        {
            // Locking the cursor to the middle of the screen
            Cursor.lockState = CursorLockMode.Locked;
        }

        void Update()
        {
        // Getting the mouse input
        float mouseX = Input.GetAxis("Mouse X") * mousesensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mousesensitivity * Time.deltaTime;

        // Rotating the camera based on the mouse input
        xRotation -= mouseY;

        // Clamping the rotation of the camera so it doesn't go all the way around
        xRotation = Mathf.Clamp(xRotation, topClamp, bottomClamp);
        yRotation += mouseX;
        transform.localRotation = Quaternion.Euler(xRotation, yRotation, 0f);

    }
}

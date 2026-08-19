using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public static PlayerController instance;
    public static Dictionary<string, int> inventory = new Dictionary<string, int>();
    public static int completedMissionCount = 0;
    private float playerSpeed = 5.0f;
    private float runSpeed = 9;
    private float jumpHeight = 1.5f;
    private float gravityValue = -9.81f;
    public CharacterController controller;
    private Vector3 playerVelocity;
    private bool groundedPlayer;

    public Transform head;
    [Header("Input Actions")]
    public InputActionReference moveAction;
    public InputActionReference jumpAction;

    private void OnEnable()
    {
        instance = this;
        moveAction.action.Enable();
        jumpAction.action.Enable();
    }

    private void OnDisable()
    {
        moveAction.action.Disable();
        jumpAction.action.Disable();
    }
    Vector3 forward;
    public Vector2 input => moveAction.action.ReadValue<Vector2>();
    void Update()
    {
        groundedPlayer = controller.isGrounded;

        if (groundedPlayer)
        {
            // Slight downward velocity to keep grounded stable
            if (playerVelocity.y < -2f)
                playerVelocity.y = -2f;
        }

        // Read input
        Vector3 move = new Vector3(input.x, 0, input.y);
        move = Vector3.ClampMagnitude(move, 1f);
        if(input != Vector2.zero) forward = Vector3.Lerp(forward, move, playerSpeed * Time.deltaTime);
        transform.forward = forward;

        // Jump using WasPressedThisFrame()
        if (groundedPlayer && jumpAction.action.IsPressed())
        {
            playerVelocity.y = Mathf.Sqrt(jumpHeight * -2f * gravityValue);
        }

        // Apply gravity
        playerVelocity.y += gravityValue * Time.deltaTime;

        // Move
        Vector3 finalMove = move * (jumpAction.action.IsPressed() ? runSpeed : playerSpeed) + Vector3.up * playerVelocity.y;
        controller.Move(finalMove * Time.deltaTime);
    }
}

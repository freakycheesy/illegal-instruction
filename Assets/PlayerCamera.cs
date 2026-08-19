using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerCamera : MonoBehaviour
{
    public float lerp;
    public Vector3 offset;
    public Vector3 zoomOffset;
    private Camera m_Camera;
    public InputActionReference zoomButton;
    public float zoomFOV;
    public float defaultFOV;
    private void Start()
    {
        m_Camera = GetComponent<Camera>();
    }
    private void OnEnable()
    {
        zoomButton.action.Enable();
    }
    private void OnDisable()
    {
        zoomButton.action.Disable();
    }

    private void Update()
    {
        if (!PlayerController.instance) return;
        bool zoomin = zoomButton.action.IsPressed();
        m_Camera.fieldOfView = zoomin ? Mathf.Lerp(m_Camera.fieldOfView, zoomFOV, lerp * Time.deltaTime) : Mathf.Lerp(m_Camera.fieldOfView, defaultFOV, lerp * Time.deltaTime);
        Vector3 offset = zoomin ? this.zoomOffset : this.offset;
        transform.position = Vector3.Lerp(transform.position, PlayerController.instance.head.position + offset, lerp * Time.deltaTime);
        transform.LookAt(PlayerController.instance.head.position);
    }
}

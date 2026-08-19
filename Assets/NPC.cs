using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class NPC : MonoBehaviour
{
    public float activationDistance = 6f;
    [TextArea(1, 5)]
    public string dialog;

    public Animator animator;
    public TMP_Text text;
    public Transform speechBubble;
    public bool active;
    private bool _activated;
    public UnityEvent activeEvent;
    public UnityEvent inactiveEvent;
    private void Start()
    {
        text.text = dialog;
    }
    private void Update()
    {
        speechBubble.LookAt(Camera.main.transform);
        speechBubble.forward = -speechBubble.forward;
        active = Vector3.Distance(PlayerController.instance.transform.position, transform.position) <= activationDistance;
        if (active && !_activated) {
            _activated = true;
            activeEvent?.Invoke();
        }
        else if (!active && _activated) { 
            _activated = false;
            inactiveEvent?.Invoke();
        }
        animator.SetBool("speak", active);
    }
}

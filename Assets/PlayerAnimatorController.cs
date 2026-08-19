using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimatorController : MonoBehaviour
{
    public Animator animator;
    public PlayerController controller;
    void Update()
    {
        animator.SetFloat("move", controller.input.magnitude);
    }
}

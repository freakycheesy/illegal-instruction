using System;
using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.SceneManagement;

public class Him : MonoBehaviour
{
    private NavMeshAgent agent;
    private void Start()
    {
        agent = GetComponent<NavMeshAgent>();
    }
    private bool chase = false;
    private void Update()
    {     
        if (!chase) {
            if (Vector3.Distance(PlayerController.instance.transform.position, transform.position) < 10)
            {
                chase = true;
                GetComponent<Animator>().enabled = true;
            }
            return;
        }
        agent.speed += Time.deltaTime * 0.1f;
        agent.SetDestination(PlayerController.instance.transform.position);
        if (Vector3.Distance(PlayerController.instance.transform.position, transform.position) > 20)
        {
            PlayerController.instance.controller.enabled = false;
            PlayerController.instance.transform.position = agent.pathEndPosition;
            PlayerController.instance.controller.enabled = true;
            Camera.main.transform.position = PlayerController.instance.transform.position;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            GetComponent<Animator>().enabled = false;
            agent.enabled = false;
            StartCoroutine(LoadReveal());      
        }
    }

    private IEnumerator LoadReveal()
    {
        while (!SceneManager.LoadSceneAsync("Reveal").isDone)
        {
            yield return null;
        }
    }
}

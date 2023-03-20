using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;

public class Soldier : MonoBehaviour
{
    private Animator anim;
    private NavMeshAgent agent;
    private GameObject footEffect;

    private Camera mainCam;

    private SelectedFrameController controller;

    private LayerMask groundLayer;
    
    public bool IsSelected { get; private set; }= false;

    private Vector3 targetPos;
    
    private void Awake()
    {
        anim = GetComponentInChildren<Animator>();
        agent = GetComponent<NavMeshAgent>();
        footEffect = transform.GetChild(1).gameObject;
        
        mainCam = Camera.main;

        controller = FindObjectOfType<SelectedFrameController>();

        groundLayer = 1 << 6;
        
        SwitchBeSelected(false);
    }

    private void Update()
    {
        if (controller.isMosDraging) return;
        
        if (!IsSelected) return;
        
        anim.SetBool("Walk",agent.velocity.magnitude > Mathf.Epsilon);

        if (Input.GetMouseButtonDown(1))
        {
            var ray = mainCam.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out var hit, groundLayer))
            {
                Move(hit.point);
            }
        }
    }

    public void Move(Vector3 target)
    {
        targetPos = target;
        agent.SetDestination(targetPos);
    }

    public void SwitchBeSelected(bool beSelected)
    {
        IsSelected = beSelected;
        footEffect.SetActive(IsSelected);
    }
}

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectedFrameController : MonoBehaviour
{
    private LineRenderer line;
    
    private Camera mainCam;

    public bool isMosDraging { get; private set; } = false;

    private Vector3 beginDragPos;
    private Vector3 curMosPos;

    private Vector3 rightUpPoint;
    private Vector3 leftDownPoint;
    private Vector3 rightDownPoint;
    private Vector3 leftUpPoint;

    private Vector3 frameCenterPoint = Vector3.zero;
    private Vector3 halfExtents = Vector3.zero;
    private Vector3 rayBeginPoint = Vector3.zero;

    private RaycastHit hit;

    //相机Z轴在横截面上向前推动的距离
    [SerializeField] private float cameraZ;
    //框选范围判断抬高的Y值
    [SerializeField] private float selectedRangeCubeY;

    [SerializeField] private int soldierListMaxNum;
    [SerializeField] private List<Soldier> curSelectedSoldierList = new List<Soldier>();

    private const int LinePointNum = 4;

    private LayerMask characterLayer;
    private LayerMask groundLayer;
    
    private void Awake()
    {
        line = GetComponent<LineRenderer>();
        
        mainCam = Camera.main;

        groundLayer = 1 << 6;
        characterLayer= 1 << 7;
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            isMosDraging = true;
            beginDragPos = Input.mousePosition;

            ResetSoldierList();

            
            if(Physics.Raycast(mainCam.ScreenPointToRay(Input.mousePosition), out hit, 1000f, characterLayer))
            {
                if (TryGetComponent<Soldier>(out var soldier))
                {
                    soldier.SwitchBeSelected(!soldier.IsSelected);
                }
            }
            else if (Physics.Raycast(mainCam.ScreenPointToRay(Input.mousePosition), out hit, 1000f, groundLayer))
            {
                rayBeginPoint = hit.point;
            }
              
        }
        else if (Input.GetMouseButtonUp(0))
        {
            isMosDraging = false;
            line.positionCount = 0;

            SelectSoldiers();
        }
        
        if(!isMosDraging) return;
        
        DrawSelectedFrame();
    }

    private void DrawSelectedFrame()
    {
        beginDragPos.z = cameraZ;
        curMosPos = Input.mousePosition;
        curMosPos.z = cameraZ;

        rightUpPoint = beginDragPos;
        leftDownPoint = curMosPos;
        
        rightDownPoint.x = rightUpPoint.x;
        rightDownPoint.y = leftDownPoint.y;
        rightDownPoint.z = cameraZ;
        leftUpPoint.x = leftDownPoint.x;
        leftUpPoint.y = rightUpPoint.y;
        leftUpPoint.z = cameraZ;

        line.positionCount = LinePointNum;
        
        line.SetPosition(0,mainCam.ScreenToWorldPoint(rightUpPoint));
        line.SetPosition(1,mainCam.ScreenToWorldPoint(leftUpPoint));
        line.SetPosition(2,mainCam.ScreenToWorldPoint(leftDownPoint));
        line.SetPosition(3,mainCam.ScreenToWorldPoint(rightDownPoint));
    }

    private void SelectSoldiers()
    {
        if (Physics.Raycast(mainCam.ScreenPointToRay(Input.mousePosition), out hit, 1000f, groundLayer))
        {
            //求出画出立方体的中心点
            frameCenterPoint.x = (rayBeginPoint.x + hit.point.x) / 2;
            frameCenterPoint.y = selectedRangeCubeY;
            frameCenterPoint.z = (rayBeginPoint.z + hit.point.z) / 2;

            halfExtents.x = Mathf.Abs((hit.point.x - rayBeginPoint.x) / 2);
            halfExtents.z = Mathf.Abs((hit.point.z - rayBeginPoint.z) / 2);
            halfExtents.y = selectedRangeCubeY;
                
            var colliders = Physics.OverlapBox(frameCenterPoint, halfExtents);

            if (colliders.Length > 0)
            {
                foreach (var collider in colliders)
                {
                    if (!collider.TryGetComponent<Soldier>(out var soldier)) continue;
                    if(curSelectedSoldierList.Contains(soldier)) continue;
                            
                    curSelectedSoldierList.Add(soldier);
                    soldier.SwitchBeSelected(true);
                }
            }
        }
    }

    private void ResetSoldierList()
    {
        if (curSelectedSoldierList.Count == 0) return;

        foreach (var soldier in curSelectedSoldierList)
        {
            soldier.SwitchBeSelected(false);
        }
        
        curSelectedSoldierList.Clear();
    }

    public void RemoveSoldier(Soldier soldier)
    {
        if(!curSelectedSoldierList.Contains(soldier)) return;

        curSelectedSoldierList.Remove(soldier);
    }

    
}

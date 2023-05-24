using System.Collections.Generic;
using UnityEngine;

public class CameraMover : MonoBehaviour
{
    [SerializeField]
    private List<Transform> Positions;

    [SerializeField]
    private float WaitTimeSeconds = 1.5f;

    [SerializeField]
    private float MoveTimeSeconds = 0.5f;

    private int _currentPositionIndex = 0;
    private int _nextPositionIndex = 1;
    
    private float _waitTime = 0;

    private void Update()
    {
        _waitTime += Time.deltaTime;
        if (_waitTime > WaitTimeSeconds)
        {
            if (_waitTime > WaitTimeSeconds + MoveTimeSeconds)
            {
                LerpToNextPosition(1.0f);
                
                _waitTime = 0.0f;

                _currentPositionIndex = _nextPositionIndex;
                _nextPositionIndex = GetNextPosition(_nextPositionIndex, Positions.Count);
            }
            else
            {
                float percent = Mathf.Clamp01((_waitTime - WaitTimeSeconds) / MoveTimeSeconds);
                LerpToNextPosition(percent);
            }
        }
    }

    private void LerpToNextPosition(float percent)
    {
        Vector3 position = Vector3.Lerp(Positions[_currentPositionIndex].position, Positions[_nextPositionIndex].position, percent);
        Quaternion rotation = Quaternion.Lerp(Positions[_currentPositionIndex].rotation, Positions[_nextPositionIndex].rotation, percent);
        
        transform.SetPositionAndRotation(position, rotation);
    }

    private static int GetNextPosition(int currentPosition, int count)
    {
        return (currentPosition + 1) % count;
    }
}

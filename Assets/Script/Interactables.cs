using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Interactables : MonoBehaviour
{
    //message displayed to the player when they can interact with the object
    public string promptMessage;
    public void BaseInteract()
    {
        Interact();
    }

    protected virtual void Interact()
    {
        //template
    }

}


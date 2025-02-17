//Tool created by Nebula Animations

using UnityEditor;
using UnityEngine;

public class ZZZHollowed : EditorWindow
{
    private Material replacementMaterial;
    private static Material defaultMaterial;
    private Texture2D headerImage;
    
    private const float windowWidth = 395f;
    private const float windowHeight = 475f;

    private const string copyPrefix = "ZZZ_Hollow_Object_";

    [MenuItem("Tools/ZZZ Hollow")]
    public static void ShowWindow()
    {
        ZZZHollowed window = GetWindow<ZZZHollowed>("ZZZ Hollow");
        window.minSize = new Vector2(windowWidth, windowHeight);
        window.maxSize = new Vector2(windowWidth, windowHeight);
    }
    private void OnEnable()
    {
        headerImage = (Texture2D)EditorGUIUtility.Load("Assets/Nebula Animations/Zenless Zone Zero/World/EnviromentDigitizationEffect/Resources/Hollow_Bannar_Tool.jpg");
        
        InitializeDefaultMaterial();

        if (headerImage == null)
        {
            Debug.LogError("Header image not found! Please check the path.");
        }
    }

    private void OnGUI()
    {
        // Header Image
        if (headerImage != null)
        {
            GUILayout.Label(headerImage, GUILayout.Height(100));
        }

        GUILayout.Label("Created By: Nebula Animations", EditorStyles.boldLabel);

        GUIStyle labelStyle = new GUIStyle(EditorStyles.boldLabel);
        if (replacementMaterial == null)
        {
            labelStyle.normal.textColor = Color.green;
            GUILayout.Label("Using default material.", labelStyle);
        }
        else
        {
            labelStyle.normal.textColor = Color.red;
            GUILayout.Label("Using selected material.", labelStyle);
        }

        GUILayout.Space(5);

        EditorGUILayout.HelpBox("This tool is only designed to be used with objects containing the mesh renderer component, Skinned Mesh Renderer is not supported.", MessageType.Warning);
        EditorGUILayout.HelpBox("You can select your own material below if you want to use this tool for other purposes but by default the Hollow material will be applied.", MessageType.Info);
        GUILayout.Space(5);

        GUILayout.Label("Select Alternate Material", EditorStyles.boldLabel);

        replacementMaterial = (Material)EditorGUILayout.ObjectField("Material", replacementMaterial, typeof(Material), false);

        GUILayout.Space(10);

        GUILayout.Label("Select a object, then click add or remove effect.", EditorStyles.boldLabel);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Add Effect", GUILayout.Height(40)))
        {
            CopySelectedMesh();
        }

        if (GUILayout.Button("Remove Effect", GUILayout.Height(40)))
        {
            RemoveSelected();
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(10);

        if (GUILayout.Button("Remove Effect From Everything in Current Scene", GUILayout.Height(40)))
        {
            RemoveAllCopiesWithConfirmation();
        }

        GUILayout.Space(10);

        // Social Media Links
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("Twitter", GUILayout.Width(100)))
        {
            Application.OpenURL("https://x.com/NebulaAnimation"); 
        }
        GUILayout.Space(10);
        if (GUILayout.Button("Gumroad", GUILayout.Width(100)))
        {
            Application.OpenURL("https://nebulaanimations.gumroad.com/"); 
        }
        GUILayout.Space(10);
        if (GUILayout.Button("Website", GUILayout.Width(100)))
        {
            Application.OpenURL("https://nebulaanimations.com/"); 
        }
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        GUILayout.Space(10);

        EditorGUILayout.HelpBox("This is a fan-made tool for Unity that has no association or endorsement by Hoyoverse. Ensure you have backups of your work before using this tool.", MessageType.Info);
        
        GUILayout.Space(10);
    }

    private void CopySelectedMesh()
    {
        Material materialToUse = replacementMaterial ? replacementMaterial : defaultMaterial;

        if (materialToUse == null)
        {
            Debug.LogError("No replacement or default material set!");
            return;
        }

        GameObject selectedObject = Selection.activeGameObject;

        if (selectedObject == null)
        {
            Debug.LogError("No game object selected!");
            return;
        }

        MeshFilter meshFilter = selectedObject.GetComponent<MeshFilter>();

        if (meshFilter == null)
        {
            Debug.LogError("Selected object does not have a mesh filter!");
            return;
        }

        // Create a copy of the selected object
        GameObject copiedObject = Instantiate(selectedObject, selectedObject.transform.position, selectedObject.transform.rotation);
        copiedObject.name = "ZZZ_Hollow_Object_" + selectedObject.name;
        copiedObject.transform.parent = selectedObject.transform;

        // Replace all materials
        Renderer[] renderers = copiedObject.GetComponentsInChildren<Renderer>();
        foreach (Renderer renderer in renderers)
        {
            Material[] newMaterials = new Material[renderer.sharedMaterials.Length];
            for (int i = 0; i < newMaterials.Length; i++)
            {
                newMaterials[i] = materialToUse;
            }
            renderer.sharedMaterials = newMaterials;
        }

        Debug.Log("Mesh copied and materials replaced successfully.");
    }

    private void RemoveAllCopiesWithConfirmation()
    {
        if (EditorUtility.DisplayDialog("Remove Effect",
            "Are you sure you want to remove the effect from all objects in this scene? This action cannot be undone.",
            "Yes", "No"))
        {
            RemoveAllCopies();
        }
    }
    private void RemoveAllCopies()
    {
        GameObject[] allObjects = GameObject.FindObjectsOfType<GameObject>();
        foreach (GameObject obj in allObjects)
        {
            if (obj.name.StartsWith(copyPrefix))
            {
                DestroyImmediate(obj);
            }
        }

        Debug.Log("All copies removed successfully.");
    }

    private void RemoveSelected()
    {
        GameObject selectedObject = Selection.activeGameObject;

        if (selectedObject == null)
        {
            Debug.LogError("No game object selected!");
            return;
        }

        if (selectedObject.name.StartsWith(copyPrefix))
        {
                DestroyImmediate(selectedObject);
                Debug.Log("Removed successfully.");
                return;
        }

        // Call a recursive function to remove objects matching the prefix
        RemoveObjectsByName(selectedObject.transform, copyPrefix);

        Debug.Log("Removed successfully.");
    }

    private void RemoveObjectsByName(Transform parent, string prefix)
    {
        for (int i = parent.childCount - 1; i >= 0; i--)
        {
            Transform child = parent.GetChild(i);
            if (child.gameObject.name.StartsWith(prefix))
            {
                DestroyImmediate(child.gameObject);
            }
            else
            {
                // Recursively check children
                RemoveObjectsByName(child, prefix);
            }
        }
    }
    
    [InitializeOnLoadMethod]
    private static void InitializeDefaultMaterial()
    {
        // Set your default material here
        defaultMaterial = AssetDatabase.LoadAssetAtPath<Material>("Assets/Nebula Animations/Zenless Zone Zero/World/EnviromentDigitizationEffect/Materials/WorldMappedVertexShaderZZZ.mat");

        if (defaultMaterial == null)
        {
            Debug.LogWarning("Default material not found! Please assign a valid path.");
        }
    }
}

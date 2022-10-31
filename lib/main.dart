import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const FaceDetectionPage());
}

class ARSphere extends StatefulWidget {
  const ARSphere({super.key});

  @override
  State<ARSphere> createState() => _ARSphereState();
}

class _ARSphereState extends State<ARSphere> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final node = ARKitNode(
      geometry: ARKitSphere(radius: 0.1),
      position: vector.Vector3(0, 0, -0.5),
    );
    this.arkitController.add(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARKit in Flutter'),
      ),
      body: ARKitSceneView(
        onARKitViewCreated: onARKitViewCreated,
      ),
    );
  }
}

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late ARKitController arKitController;

  ARKitNode? node;
  ARKitNode? leftEye;
  ARKitNode? rightEye;

  @override
  void dispose() {
    arKitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void onARKitViewCreated(ARKitController arKitController) {
    this.arKitController = arKitController;
    this.arKitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arKitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitFaceAnchor) {
      return;
    }

    final material = ARKitMaterial(fillMode: ARKitFillMode.lines);
    anchor.geometry.materials.value = [material];

    node = ARKitNode(geometry: anchor.geometry);
    arKitController.add(
      node!,
      parentNodeName: anchor.nodeName,
    );

    leftEye = _createEye(anchor.leftEyeTransform);
    arKitController.add(
      leftEye!,
      parentNodeName: anchor.nodeName,
    );

    rightEye = _createEye(anchor.rightEyeTransform);
    arKitController.add(
      rightEye!,
      parentNodeName: anchor.nodeName,
    );
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitFaceAnchor && mounted) {
      final faceAnchor = anchor;
      arKitController.updateFaceGeometry(node!, anchor.identifier);

      _updateEye(
        leftEye!,
        faceAnchor.leftEyeTransform,
        faceAnchor.blendShapes['eyeBlink_L'] ?? 0,
      );

      _updateEye(
        rightEye!,
        faceAnchor.rightEyeTransform,
        faceAnchor.blendShapes['eyeBlink_R'] ?? 0,
      );
    }
  }

  ARKitNode _createEye(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.yellow),
    );
    final sphere = ARKitBox(
      materials: [material],
      width: 0.03,
      height: 0.03,
      length: 0.03,
    );

    return ARKitNode(
      geometry: sphere,
      position: position,
    );
  }

  void _updateEye(ARKitNode node, Matrix4 transform, double blink) {
    final scale = vector.Vector3(1, 1 - blink, 1);
    node.scale = scale;
  }
}

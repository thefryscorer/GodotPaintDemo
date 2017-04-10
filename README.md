# Godot UV Painting Demo

[Video](https://youtu.be/twAfBUUlGws)

This is an example project to demonstrate how to get a UV co-ordinate from a point on a model, and the normal (both easily obtained from a ray cast).

## Requirements and limitations:
  - The mesh needs to have a collision shape that exactly matches the mesh, in order to compare the values from a raycast to the faces of the mesh. This can be done using primitive shaped meshes, or by using the Better Collada Exporter in Blender (and appending "-col" to the names of meshes you want to generate collision shapes for) and importing the scene into Godot.
  - The mesh also needs to be UV unwrapped, and have a fixed material with a diffuse texture (although it is also easy to create and apply the diffuse texture within a script).
  - The mesh should probably be triangulated. I haven't tested with one that isn't.
  - If the brush transfer is large-ish and the UV layout contains many small faces that do not necessarily align with their position on the mesh, the brush transfer may go outside of the bounds of that face and appear on other parts of the mesh. One way to work around this might be to use several ray casts to find points in a small circular area and use put_pixel instead of brush_transfer, but this would likely impact performance. Another would be to make sure the brush_transfer is only affecting faces that are close to the face hit by the ray cast. I'd also recommend UV unwrapping models in a way that would minimise overlapping, and place the seams somewhere mostly out of sight.
  - At the moment this is hardcoded for just one mesh in the scene, it could be extended to work with multiple meshes though using the same technique.

## Basic idea:

This method uses Godot's MeshDataTool to get faces, vertices, and the UV co-ordinates of vertices of the mesh.

To find the UV co-ordinates from a point and a normal, first the normal is compared to every face of the mesh, to find candidate faces. From there, those candidate faces are checked to see if they contain the point. Once a face has been found that matches the normal, and contains the point, we get the positions of the vertices and get the barycentric co-ordinates of the point within that triangle. Then we get the UV co-ordinates of each vertex, and use the barycentric coordinates to find the UV co-ordinates of the point on the mesh.


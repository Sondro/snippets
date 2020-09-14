package;

import OgexData;
import haxebullet.Bullet;

class Physics 
{
	public var m:haxebullet.BtMotionState;
	public var collisionMesh:BtTriangleMesh;

	public var dynamicsWorld:BtDiscreteDynamicsWorld;
	public var controllerAngle:Float = 0;
	public var cameraAngle:Float = 0;

	public inline function new():Void 
	{
//---------------------------------------------------------------------------
// Collision
//---------------------------------------------------------------------------

		var collisionConfiguration = BtDefaultCollisionConfiguration.create();
		var dispatcher = BtCollisionDispatcher.create(collisionConfiguration);
		var broadphase = BtDbvtBroadphase.create();
		var solver = BtSequentialImpulseConstraintSolver.create();
		dynamicsWorld = BtDiscreteDynamicsWorld.create(dispatcher,broadphase,solver,collisionConfiguration);
		dynamicsWorld.setGravity(BtVector3.create(0,-50,0));

		collisionMesh = BtTriangleMesh.create(true,false);

 		Main.app.startExtracting = true;

//---------------------------------------------------------------------------
		
	}

	public inline function setUpCollision(data_geoObjs:Array<GeometryObject>,scaleCollisions:Float):Void 
	{
		var sumTris:Int;
		var verts:Array<Float>;
		var indexes:Array<Int>;
			
		var i0:Int;
		var i1:Int;
		var i2:Int;

		var i0p:Int;
		var i1p:Int;
		var i2p:Int;
		
		//var objLen = data_geoObjs.length;

		var mod0 = 3;

		for(obj in data_geoObjs) 
		{
			sumTris = Std.int(obj.mesh.indexArray.values.length / mod0);
			verts = obj.mesh.vertexArrays[0].values;
			indexes = obj.mesh.indexArray.values;
			
			for(i in 0...sumTris)
			{
				i0p = i * mod0;

				i0 = indexes[i0p];
				i1 = indexes[i0p+1];
				i2 = indexes[i0p+2];

				i0p = i0 * mod0;
				i1p = i1 * mod0;
				i2p = i2 * mod0;

				collisionMesh.addTriangle
				(
					BtVector3.create(verts[i0p] * scaleCollisions,verts[i0p+1] * scaleCollisions,verts[i0p+2] * scaleCollisions),
					BtVector3.create(verts[i1p] * scaleCollisions,verts[i1p+1] * scaleCollisions,verts[i1p+2] * scaleCollisions),
					BtVector3.create(verts[i2p] * scaleCollisions,verts[i2p+1] * scaleCollisions,verts[i2p+2] * scaleCollisions),
					true
				);
			}
		}
	
///////////////////////////////////////////////////////////////////////
//	Physics:
///////////////////////////////////////////////////////////////////////
		var groundShape = BtBvhTriangleMeshShape.create(collisionMesh,true,true);
		var groundTransform = BtTransform.create();
		groundTransform.setIdentity();
		groundTransform.setOrigin(BtVector3.create(0,-1,0));
		var centerOfMassOffsetTransform = BtTransform.create();
		centerOfMassOffsetTransform.setIdentity();
		var groundMotionState = BtDefaultMotionState.create(groundTransform,centerOfMassOffsetTransform);
		var groundRigidBodyCI = BtRigidBodyConstructionInfo.create(0,groundMotionState,groundShape,BtVector3.create(0,0,0));
		
		var groundRigidBody = BtRigidBody.create(groundRigidBodyCI);
		groundRigidBody.setCollisionFlags(BtCollisionObject.CF_STATIC_OBJECT);
		dynamicsWorld.addRigidBody(groundRigidBody);

		var fallShape = BtCapsuleShape.create(1,1);
		var fallTransform = BtTransform.create();
		fallTransform.setIdentity();
		fallTransform.setOrigin(BtVector3.create(0,10,120.0));
		var centerOfMassOffsetFallTransform = BtTransform.create();
		centerOfMassOffsetFallTransform.setIdentity();
		var fallMotionState = BtDefaultMotionState.create(fallTransform,centerOfMassOffsetFallTransform);

		var fallInertia = BtVector3.create(0,0,0);
		fallShape.calculateLocalInertia(1,fallInertia);
		var fallRigidBodyCI = BtRigidBodyConstructionInfo.create(1,fallMotionState,fallShape,fallInertia);

		Main.app.p1Actor.fallRigidBody = BtRigidBody.create(fallRigidBodyCI);
		Main.app.p1Actor.fallRigidBody.setAngularFactor(BtVector3.create(0,1,0));
		dynamicsWorld.addRigidBody(Main.app.p1Actor.fallRigidBody);
		Main.app.p1Actor.fallRigidBody.activate(true);
	}

	inline public function update():Void
	{
		dynamicsWorld.stepSimulation(Main.app.timeFPS);
		m = Main.app.p1Actor.fallRigidBody.getMotionState();
		m.getWorldTransform(Main.app.p1Actor.trans);

		Main.app.p1Actor.vel = Main.app.p1Actor.fallRigidBody.getLinearVelocity();
		
		if(Main.app.p1Actor.dir.x != 0) { Main.app.p1Actor.dir.x = 0; }
		if(Main.app.p1Actor.dir.y != 0) { Main.app.p1Actor.dir.y = 0; }

		Main.app.modelMatrix._30 = Main.app.p1Actor.trans.getOrigin().x() * 10;
		Main.app.modelMatrix._31 =  Main.app.p1Actor.trans.getOrigin().y() * 10;
		Main.app.modelMatrix._32 =  Main.app.p1Actor.trans.getOrigin().z() * 10;
	}

	inline public function update2():Void
	{
		Main.app.velZ = Main.app.p1Actor.vel.y();

		Main.app.p1Actor.fallVec3.setX(Main.app.p1Actor.dir.x);
		Main.app.p1Actor.fallVec3.setY(Main.app.velZ);		
		Main.app.p1Actor.fallVec3.setZ(Main.app.p1Actor.dir.y);

		Main.app.p1Actor.fallRigidBody.setLinearVelocity(Main.app.p1Actor.fallVec3);
		Main.app.isDirUpdated = true;
	}

	inline public function rotate():Void
	{
		Main.app.modelMatrix = Main.app.modelMatrix.multmat(kha.math.FastMatrix4.rotationZ(Main.app.p1Actor.actorAngle - Main.app.p1Actor.angle));
		Main.app.actorMatrixAngle += Main.app.p1Actor.actorAngle - Main.app.p1Actor.angle;
		Main.app.p1Actor.actorAngle = Main.app.p1Actor.angle;
	}

	inline public function translate(x,y,z):Void
	{
		Main.app.p1Actor.pos.setX(x);
		Main.app.p1Actor.pos.setY(y);
		Main.app.p1Actor.pos.setZ(z);
		
		Main.app.p1Actor.trans.setOrigin(Main.app.p1Actor.pos);

		Main.app.p1Actor.pos = Main.app.p1Actor.trans.getOrigin();
		Main.app.p1Actor.fallRigidBody.setCenterOfMassTransform(Main.app.p1Actor.trans);
	}
}

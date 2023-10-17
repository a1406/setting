Table of Contents
=================
* [修改线速度](#change-linear-velocity)
* [修改坐标](#change-transform)
* [重力的计算](#重力的计算)
* [力到速度的计算](#force-velocity)
* [刚体创建](#create)

<a id="change-linear-velocity"></a>
## 修改线速度
```C++
>	btRigidBody::setLinearVelocity(const btVector3 & lin_vel) 行 445	C++
 	btSequentialImpulseConstraintSolver::writeBackBodies(int iBegin, int iEnd, const btContactSolverInfo & infoGlobal) 行 1824	C++
 	btSequentialImpulseConstraintSolver::solveGroupCacheFriendlyFinish(btCollisionObject * * bodies, int numBodies, const btContactSolverInfo & infoGlobal) 行 1848	C++
 	btSequentialImpulseConstraintSolver::solveGroup(btCollisionObject * * bodies, int numBodies, btPersistentManifold * * manifoldPtr, int numManifolds, btTypedConstraint * * constraints, int numConstraints, const btContactSolverInfo & infoGlobal, btIDebugDraw * debugDrawer, btDispatcher * __formal) 行 1869	C++
 	InplaceSolverIslandCallback::processConstraints() 行 185	C++
 	btDiscreteDynamicsWorld::solveConstraints(btContactSolverInfo & solverInfo) 行 706	C++
 	btDiscreteDynamicsWorld::internalSingleStepSimulation(float timeStep) 行 486	C++
 	btDiscreteDynamicsWorld::stepSimulation(float timeStep, int maxSubSteps, float fixedTimeStep) 行 435	C++
 	CommonRigidBodyBase::stepSimulation(float deltaTime) 行 79	C++
```
<a id="change-transform"></a>
## 修改坐标
```C++
>	btRigidBody::setCenterOfMassTransform(const btTransform & xform) 行 411	C++
 	btRigidBody::proceedToTransform(const btTransform & newTrans) 行 224	C++
 	btDiscreteDynamicsWorld::integrateTransformsInternal(btRigidBody * * bodies, int numBodies, float timeStep) 行 1044	C++
 	btDiscreteDynamicsWorld::integrateTransforms(float timeStep) 行 1056	C++
 	btDiscreteDynamicsWorld::internalSingleStepSimulation(float timeStep) 行 489	C++
 	btDiscreteDynamicsWorld::stepSimulation(float timeStep, int maxSubSteps, float fixedTimeStep) 行 435	C++
```

## 重力的计算
```C++

```

<a id="force-velocity"></a>
## 力到速度的计算
```C++
// 当前速度
solverBody->m_linearVelocity = rb->getLinearVelocity();
// 当前的力计算timeStep里的位移
solverBody->m_externalForceImpulse = rb->getTotalForce() * rb->getInvMass() * timeStep;
```

```C++
>	btSequentialImpulseConstraintSolver::initSolverBody(btSolverBody * solverBody, btCollisionObject * collisionObject, float timeStep) 行 477	C++
 	btSequentialImpulseConstraintSolver::getOrInitSolverBody(btCollisionObject & body, float timeStep) 行 776	C++
 	btSequentialImpulseConstraintSolver::convertBodies(btCollisionObject * * bodies, int numBodies, const btContactSolverInfo & infoGlobal) 行 1377	C++
 	btSequentialImpulseConstraintSolver::solveGroupCacheFriendlySetup(btCollisionObject * * bodies, int numBodies, btPersistentManifold * * manifoldPtr, int numManifolds, btTypedConstraint * * constraints, int numConstraints, const btContactSolverInfo & infoGlobal, btIDebugDraw * debugDrawer) 行 1489	C++
 	btSequentialImpulseConstraintSolver::solveGroup(btCollisionObject * * bodies, int numBodies, btPersistentManifold * * manifoldPtr, int numManifolds, btTypedConstraint * * constraints, int numConstraints, const btContactSolverInfo & infoGlobal, btIDebugDraw * debugDrawer, btDispatcher * __formal) 行 1865	C++
 	InplaceSolverIslandCallback::processConstraints() 行 185	C++
 	btDiscreteDynamicsWorld::solveConstraints(btContactSolverInfo & solverInfo) 行 706	C++
 	btDiscreteDynamicsWorld::internalSingleStepSimulation(float timeStep) 行 486	C++
 	btDiscreteDynamicsWorld::stepSimulation(float timeStep, int maxSubSteps, float fixedTimeStep) 行 435	C++
 	CommonRigidBodyBase::stepSimulation(float deltaTime) 行 79	C++
```

<a id="create"></a>
## 刚体创建
createRigidBody



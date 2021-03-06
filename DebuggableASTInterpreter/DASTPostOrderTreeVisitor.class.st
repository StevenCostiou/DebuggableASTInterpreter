Class {
	#name : #DASTPostOrderTreeVisitor,
	#superclass : #Object,
	#instVars : [
		'stack'
	],
	#category : #DebuggableASTInterpreter
}

{ #category : #visiting }
DASTPostOrderTreeVisitor >> initialize [ 

	super initialize.
	stack := Stack new
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> stack [
	^ stack
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> top [
	
	^ stack top
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitArgumentNode: aRBArgumentNode [ 
	^ stack push: aRBArgumentNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitArrayNode: aRBArrayNode [ 
	stack push: aRBArrayNode.
	aRBArrayNode children reverse do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitAssignmentNode: aRBAssignmentNode [ 

	stack push: aRBAssignmentNode.
	aRBAssignmentNode value acceptVisitor: self
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitBlockNode: aRBBlockNode [ 
	stack push: aRBBlockNode 
]

{ #category : #accessing }
DASTPostOrderTreeVisitor >> visitCascadeNode: aRBCascadeNode [ 
	stack push: aRBCascadeNode.
	aRBCascadeNode children reverse do: [ :e | e acceptVisitor: self ]
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitGlobalNode: aRBGlobalNode [ 
	stack push: aRBGlobalNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitInstanceVariableNode: aRBInstanceVariableNode [ 
	stack push: aRBInstanceVariableNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	stack push: aRBLiteralArrayNode.
	aRBLiteralArrayNode contents do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitLiteralNode: aRBLiteralValueNode [ 

	stack push: aRBLiteralValueNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitMessageNode: aRBMessageNode [ 

	stack push: aRBMessageNode.
	aRBMessageNode arguments reverse do: [ :e | e acceptVisitor: self ].
	aRBMessageNode receiver acceptVisitor: self.
	

]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitMethodNode: aRBMethodNode [ 
	
	stack push: aRBMethodNode.
	aRBMethodNode body acceptVisitor: self.
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitReturnNode: aRBReturnNode [ 
	
	stack push: aRBReturnNode.

	aRBReturnNode value acceptVisitor: self
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSelfNode: aRBSelfNode [ 
	stack push: aRBSelfNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSequenceNode: aRBSequenceNode [ 

	stack push: aRBSequenceNode.
	aRBSequenceNode children reverse do: [ :e | e acceptVisitor: self ].	
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitSuperNode: aRBSuperNode [ 
	^ stack push: aRBSuperNode
]

{ #category : #'as yet unclassified' }
DASTPostOrderTreeVisitor >> visitTemporaryNode: aRBTemporaryNode [ 
	stack push: aRBTemporaryNode
]

{ #category : #visiting }
DASTPostOrderTreeVisitor >> visitVariableNode: aRBVariableNode [ 
	
	stack push: aRBVariableNode 
]

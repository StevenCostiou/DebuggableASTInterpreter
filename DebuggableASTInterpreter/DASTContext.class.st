"
I store variables and its values. I also contain a reference to my parent context. My method find: looks for a variable in myself and up in my predecessor contexts
"
Class {
	#name : #DASTContext,
	#superclass : #Object,
	#instVars : [
		'variablesDict',
		'receiver',
		'hasReturned',
		'nodes',
		'stack',
		'senderContext',
		'parent',
		'closure',
		'messageNode',
		'environment'
	],
	#category : #DebuggableASTInterpreter
}

{ #category : #'API-store' }
DASTContext >> at: aByteSymbol put: anObject [
	^self variablesDict at: aByteSymbol put: anObject.
	
	
]

{ #category : #'accessing - private' }
DASTContext >> definesLocalVariableNamed: aName [
	"Return true if the context defines the local variable"
	^ self variablesDict keys includes: aName
]

{ #category : #'API-lookup' }
DASTContext >> findClassVariable: aName [
	^ receiver isClass 
		ifTrue: [ receiver bindingOf: aName ]
		ifFalse:[ (receiver systemClass bindingOf: aName) value ]
]

{ #category : #'API-lookup' }
DASTContext >> findInstanceVariable: aName [

	[^ self receiver instVarNamed: aName]
		on: InstanceVariableNotFound do: [ ^nil ] 
]

{ #category : #'API-lookup' }
DASTContext >> findLocalVariable: aName [

	^ variablesDict 
		at: aName 
		ifAbsent: [ nil ]
]

{ #category : #'API-lookup' }
DASTContext >> findVariable: aByteSymbol [
	|value|
	"Return the value of a variable. If this context redefines a variable defined by its parent context, this method will return the variable value for this context"
	
	"class variables"
	value := self findClassVariable: aByteSymbol.
	value ifNotNil: [ ^ value ].
	
	"instance variables"
	value := self findInstanceVariable: aByteSymbol.
	value ifNotNil: [ ^ value ].
	
	"local variables"
	value := self findLocalVariable: aByteSymbol.
	value ifNotNil: [ ^ value ].
	
	^ parent 
			ifNil: [ self error: 'Variable ', aByteSymbol , ' not defined!'  ] 
			ifNotNil: [ :pc | pc findVariable: aByteSymbol ]
]

{ #category : #'accessing - private' }
DASTContext >> getClassForLookup [
	| aClass |
	
	aClass := self receiver systemClass.
	 ^ aClass := (messageNode isSuperSend 
			ifTrue: [messageNode methodNode methodClass superclass] 
			ifFalse: [aClass]) .
]

{ #category : #accessing }
DASTContext >> initialize [
	super initialize.
	hasReturned := false.
	stack := Stack new.
	variablesDict := Dictionary new
]

{ #category : #initialization }
DASTContext >> initializeWithParent: aDASTContext receiver: aReceiver messageNode: aRBMessageNode [ 
	
	| parentContext compiledMethod theMethod visitor aClass aSelector |
	parentContext := aReceiver isBlock 
		ifTrue: [ aReceiver outerContext ]
		ifFalse: [ aDASTContext ].
	
	self	parentContext: parentContext;
			receiver: aReceiver;			
			senderContext: aDASTContext;
			messageNode: aRBMessageNode .
	aSelector := aRBMessageNode selector.
	
	aClass := (self receiver isNil and: [ aSelector = #value ]) 
		ifTrue: [ BlockClosure ]
		ifFalse: [ self getClassForLookup ].
	
	compiledMethod := self lookupSelector: aSelector startInClass: aClass.

	theMethod := (aReceiver isBlock and: [ compiledMethod isKindOfValue ])
		ifTrue: [ aReceiver ]
		ifFalse: [ DASTMethod new initializeWith: compiledMethod ast outerContext: aDASTContext ].
		
	visitor := DASTPostOrderTreeVisitor new.
	(theMethod doSemanticAnalysis body) acceptVisitor: visitor.
	nodes := visitor stack.
	
	self 	methodOrBlock: theMethod;
			nodes: nodes.
	
]

{ #category : #testing }
DASTContext >> isBlockContext [

	^ closure isBlock
]

{ #category : #testing }
DASTContext >> isEmpty [
	
	^ variablesDict isEmpty.
]

{ #category : #testing }
DASTContext >> isRoot [ 
	^false
]

{ #category : #'accessing - private' }
DASTContext >> lookupContextDefiningLocalVariable: aByteSymbol [
	
	(self definesLocalVariableNamed: aByteSymbol) ifTrue: [ ^ self ].
	
	^ self isBlockContext
		ifTrue: [ closure outerContext lookupContextDefiningLocalVariable: aByteSymbol ]
		ifFalse: [ nil ]
]

{ #category : #'API-lookup' }
DASTContext >> lookupSelector: aByteString startInClass: aClass [ 
	
	^ aClass lookupSelector: aByteString.
]

{ #category : #accessing }
DASTContext >> messageNode: aRBMessageNode [ 
	messageNode := aRBMessageNode
]

{ #category : #accessing }
DASTContext >> methodOrBlock [
	^ closure
]

{ #category : #accessing }
DASTContext >> methodOrBlock: aDASTClosure [

	closure := aDASTClosure
]

{ #category : #accessing }
DASTContext >> nodes [ 
	^nodes ifNil: [ nodes := Stack new ]
]

{ #category : #accessing }
DASTContext >> nodes: aStack [ 
	nodes := aStack
]

{ #category : #accessing }
DASTContext >> parentContext [
	^ parent
]

{ #category : #accessing }
DASTContext >> parentContext: aDASTContext [
	parent := aDASTContext
]

{ #category : #accessing }
DASTContext >> printOn: aStream [
	aStream
		cr;
		nextPutAll: (receiver ifNotNil: [ receiver asString ] ifNil: [ 'nil' ]);
		nextPutAll: ' <- ';
		nextPutAll: (closure ifNotNil: [ closure selector asString ] ifNil: ['nil']).
]

{ #category : #accessing }
DASTContext >> receiver [
	
	^ self isBlockContext
		ifTrue: [ closure outerContext receiver ]
		ifFalse: [ receiver ]
]

{ #category : #accessing }
DASTContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #modifying }
DASTContext >> removePragmaFromMethod [
	self halt.
	closure nodeAST removePragma: (closure nodeAST pragmas select: [ :p | p isPrimitive ]) first
]

{ #category : #accessing }
DASTContext >> senderContext [
	^ senderContext
]

{ #category : #accessing }
DASTContext >> senderContext: aDASTContext [
	senderContext := aDASTContext
]

{ #category : #accessing }
DASTContext >> setTemporalVariablesNamed: names values: values [
	values doWithIndex: 
		  [ :val :index | 
				self 
					at: (names at: index)
					 put: val ].
]

{ #category : #'accessing - private' }
DASTContext >> stack [
	^ stack
]

{ #category : #'accessing - private' }
DASTContext >> stack: anObject [
	stack := anObject
]

{ #category : #'accessing - private' }
DASTContext >> variablesDict [
	^ variablesDict
]

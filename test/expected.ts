const x = 'hello '
    //^?:  const x: "hello "
let y = 'world'
  //^?:  let y: string
const z = x + y
//    ^?:  const z: string

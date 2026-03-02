# React forwardRef、useImperativeHandle、ForwardRefExoticComponent 例子

## 一个Form，Input例子

### Input组件

```tsx
import { useState, useRef, forwardRef, useImperativeHandle, type RefAttributes, type ForwardRefExoticComponent, type PropsWithoutRef } from 'react';

type Props = RefAttributes<HTMLInputElement> &
  React.InputHTMLAttributes<HTMLElement> & {
    label: string;
  };

interface ForwardRefProps {
  value: string | undefined;
  focus: () => void;
  test: () => void;
}

type InputComponent = ForwardRefExoticComponent<PropsWithoutRef<Props> & RefAttributes<ForwardRefProps>>;

const Input: InputComponent = forwardRef<ForwardRefProps, Props>((props, ref) => {
  const { label, ...restProps } = props;
  const [input, setInput] = useState<string>('');
  const inputRef = useRef<HTMLInputElement>(null);

  useImperativeHandle(ref, () => {
    return {
      focus: () => {
        inputRef!.current!.focus();
      },
      value: inputRef?.current?.value,
      test: () => console.log('test'),
    };
  });

  return (
    <>
      <label>{label}</label>
      <input
        ref={inputRef}
        value={input}
        onChange={e => {
          setInput(e.target.value);
        }}
        {...restProps}
      />
    </>
  );
});

export type { Props as InputProps, ForwardRefProps as InputInstance };

export default Input;

```

### Form组件

menu.tsx

```tsx
import Input, { InputInstance } from "@/Input";
import React, { FormEvent, ForwardRefExoticComponent, RefAttributes, forwardRef, useRef } from "react";

type FormProps = RefAttributes<HTMLFormElement>;

const Form: ForwardRefExoticComponent<FormProps> = forwardRef((props, ref) => {
    const inputRef = useRef<InputInstance>(null);

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault();
        console.log(inputRef.current)
        const value = inputRef.current;
        inputRef?.current?.test();
        console.log('Submitted value:', value);
    };


    return (
        <form onSubmit={handleSubmit} ref={ref}>
            <button onClick={() => { inputRef.current?.focus() }}>Focus Input</button>
            <Input ref={inputRef} label="Enter something:" />
            <button type="submit">Submit</button>
        </form>
    )
});

export default Form;
```

index.tsx

```tsx
import InternalForm from './form'
import Input from '@/Input';

type InternalFormType = typeof InternalForm;
type CompoundedComponent = InternalFormType & {
	Input: typeof Input;
}

const Form = InternalForm as CompoundedComponent

Form.Input = Input;

export default Form;
```

